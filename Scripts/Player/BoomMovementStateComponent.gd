extends "res://Scripts/Physics/MovementStateComponent.gd"
class_name BoomMovementStateComponent

@export var can_buffer_jump: bool = true
@export var top_speed: float = 50
@export var top_speed_boost: float = 75
@export var accel: float = 300
@export var accel_rolling: float = 75
@export var accel_boost: float = 600
@export var base_jump_force: float = 16
@export var boost_speed: float = 75
@export var drag_coefficient: float = 0.4
@export var drag_coefficient_rolling: float = 0.25
@export var drag_coefficient_boosting: float = 0.2
@export var air_density: float = 1.225
@export var frontal_area: float = 0.5
@export var frontal_area_rolling: float = 0.2
@export var frontal_area_boosting: float = 0.25
@export var base_slope_accel_mul: float = 1.2
@export var slope_accel_mul_sprint: float = 0
@export var slope_accel_mul_rolling: float = 30
@export var downforce_mul: float = 0.8
@export var downforce_mul_boost: float = 0
##@export var player_body_path: RigidBody3D
##@export var boost_manager_path: BoostManager

@onready var player_body: RigidBody3D = $".."
@onready var boost_manager: BoostManager = $"../BoostManagerComponent"

enum MovementState {
	NORMAL = 0,
	ROLL = 1,
	BOOST = 2
}

var move_state_prev = MovementState.NORMAL
var move_state = MovementState.NORMAL
var can_boost: bool = true

signal move_state_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	movement_forces_component.air_density = air_density


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)
	move_state_prev = move_state
	if not controls.is_roll_pressed and not controls.is_boost_pressed:
		move_state = MovementState.NORMAL
	elif controls.is_roll_pressed:
		move_state = MovementState.ROLL
	elif controls.is_boost_pressed and can_boost:
		move_state = MovementState.BOOST
	else:
		move_state = MovementState.NORMAL
	
	if move_state_prev != move_state:
		emit_signal("move_state_changed", move_state, move_state_prev)
		if move_state == MovementState.BOOST:
			move_state_just_boosted()
	
	match move_state:
		MovementState.NORMAL:
			move_state_normal()
		MovementState.ROLL:
			move_state_roll()
		MovementState.BOOST:
			move_state_boost()

func move_state_just_boosted():
	# this introduces a very small exploit for launching higher than boost top speed
	# but it's not significant at all, and saves checking for aerial state to solve a bug
	# and it's a cool callback to quake movement physics, albeit not nearly as broken lol
	if player_body.get_linear_velocity().dot(controls.wish_dir) < top_speed_boost:
		movement_forces_component.launch(controls.wish_dir * top_speed_boost)
	boost_manager.just_boosted()

func move_state_normal():
	boost_manager.increment_boost()
	movement_forces_component.accel = accel
	movement_forces_component.top_speed_base = top_speed
	movement_forces_component.slope_accel_multiplier = base_slope_accel_mul
	movement_forces_component.drag_area = frontal_area
	movement_forces_component.drag_coefficient = drag_coefficient_rolling
	movement_forces_component.downforce_mul = downforce_mul
	# for the love of all that is holy do not set this to 0
	movement_forces_component.friction = 2

func move_state_roll():
	boost_manager.increment_boost()
	movement_forces_component.accel = accel_rolling
	movement_forces_component.top_speed_base = top_speed
	movement_forces_component.slope_accel_multiplier = slope_accel_mul_rolling
	movement_forces_component.drag_area = frontal_area_rolling
	movement_forces_component.drag_coefficient = drag_coefficient_rolling
	movement_forces_component.downforce_mul = downforce_mul
	# for the love of all that is holy do not set this to 0
	movement_forces_component.friction = 400

func move_state_boost():
	boost_manager.decrement_boost()
	movement_forces_component.traction_base = traction_base
	movement_forces_component.air_control = traction_base
	movement_forces_component.accel = accel_boost
	movement_forces_component.top_speed_base = top_speed_boost
	movement_forces_component.slope_accel_multiplier = 0
	movement_forces_component.drag_area = frontal_area_boosting
	movement_forces_component.drag_coefficient = drag_coefficient_boosting
	movement_forces_component.downforce_mul = downforce_mul_boost
	# for the love of all that is holy do not set this to 0
	movement_forces_component.friction = 1
