extends Node3D
class_name MovementComponent

# Licensed under MIT

# This code houses all the movement related variables and coordinates jumping and the like

@onready var physics_manager: PhysicsManager = $PhysicsManager
@onready var suspension_component: SuspensionComponent = $Suspension
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var input_manager: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"
@onready var wish_dir_basis_object: Node3D = $"../SpringArmAttachment"

@export var can_coyote_jump: bool = true
@export var can_buffer_jump: bool = true
@export var top_speed: float = 30
@export var top_speed_boost: float = 50
@export var accel: float = 130
@export var accel_rolling: float = 50
@export var accel_boost: float = 300
@export var base_jump_force: float = 16
@export var boost_speed: float = 50
@export var drag_coefficient: float = 0.4
@export var drag_coefficient_rolling: float = 0.25
@export var drag_coefficient_boosting: float = 0.2
@export var air_density: float = 1.225
@export var frontal_area: float = 0.5
@export var frontal_area_rolling: float = 0.2
@export var frontal_area_boosting: float = 0.25
@export var base_traction: float = 4400
@export var air_control: float = 400
@export var base_slope_accel_mul: float = 2
@export var slope_accel_mul_sprint: float = 0
@export var slope_accel_mul_rolling: float = 30
@export var slope_jump_mul: float = 1
@export var downforce_mul: float = 0.8
@export var downforce_mul_boost: float = 0

var velocity : Vector3 = Vector3.ZERO
var ground_direction: Vector3 = Vector3.ZERO
var ground_plane_velocity: Vector3 = Vector3.ZERO
var grounded: bool = false
var jump_available: bool = true
var can_boost: bool = true

signal grounded_state_changed
signal move_state_changed
signal apply_velocity
signal apply_force
signal change_gravity

enum GroundedState {
	GROUND = 0,
	AIR = 1
}

enum MovementState {
	NORMAL = 0,
	ROLL = 1,
	BOOST = 2
}

var grounded_state_prev = GroundedState.GROUND
var grounded_state = GroundedState.GROUND
var move_state_prev = MovementState.NORMAL
var move_state = MovementState.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready():
	physics_manager.air_density = air_density
	physics_manager.slope_jump_mul = slope_jump_mul
	input_manager.connect("jump_pressed", Callable(self, "_on_input_manager_jump_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	grounded_state_prev = grounded_state
	move_state_prev = move_state
	if grounded == true:
		grounded_state = GroundedState.GROUND
	else:
		grounded_state = GroundedState.AIR
	
	if not input_manager.is_roll_pressed and not input_manager.is_boost_pressed:
		move_state = MovementState.NORMAL
	elif input_manager.is_roll_pressed:
		move_state = MovementState.ROLL
	elif input_manager.is_boost_pressed and can_boost:
		move_state = MovementState.BOOST
	else:
		move_state = MovementState.NORMAL
	
	if grounded_state_prev != grounded_state:
		emit_signal("grounded_state_changed", grounded_state, grounded_state_prev)
		if grounded_state == GroundedState.AIR:
			coyote_jump_timer.start()
	
	if move_state_prev != move_state:
		emit_signal("move_state_changed", move_state, move_state_prev)
		if move_state == MovementState.BOOST:
			move_state_just_boosted()
	
	suspension_component.velocity = velocity
	physics_manager.velocity = velocity
	physics_manager.ground_direction = suspension_component.ground_direction
	
	match grounded_state:
		GroundedState.GROUND:
			state_ground()
		GroundedState.AIR:
			state_air()
	
	match move_state:
		MovementState.NORMAL:
			move_state_normal()
		MovementState.ROLL:
			move_state_roll()
		MovementState.BOOST:
			move_state_boost()

func state_ground() -> void:
	if not input_manager.is_jump_pressed:
		jump_available = true
	physics_manager.ground_move()

func state_air() -> void:
	if can_coyote_jump == false:
		jump_available = false
	physics_manager.air_move()

func move_state_normal() -> void:
	if grounded_state == GroundedState.GROUND:
		physics_manager.base_traction = base_traction
	else:
		physics_manager.base_traction = air_control
	
	physics_manager.accel = accel
	physics_manager.top_speed = top_speed
	physics_manager.slope_accel_multiplier = base_slope_accel_mul
	physics_manager.drag_area = frontal_area
	physics_manager.drag_coefficient = drag_coefficient_rolling
	physics_manager.downforce_mul = downforce_mul

func move_state_roll() -> void:
	if grounded_state == GroundedState.GROUND:
		physics_manager.base_traction = base_traction
	else:
		physics_manager.base_traction = air_control
	
	physics_manager.accel = accel_rolling
	physics_manager.top_speed = top_speed
	physics_manager.slope_accel_multiplier = slope_accel_mul_rolling
	physics_manager.drag_area = frontal_area_rolling
	physics_manager.drag_coefficient = drag_coefficient_rolling
	physics_manager.downforce_mul = downforce_mul

func move_state_boost() -> void:
	physics_manager.base_traction = base_traction
	physics_manager.accel = accel_boost
	physics_manager.top_speed = top_speed_boost
	physics_manager.slope_accel_multiplier = 0
	physics_manager.drag_area = frontal_area_boosting
	physics_manager.drag_coefficient = drag_coefficient_boosting
	physics_manager.downforce_mul = downforce_mul_boost

func move_state_just_boosted() -> void:
	if velocity.dot(input_manager.wish_dir) < top_speed_boost:
		physics_manager.launch(input_manager.wish_dir * top_speed_boost)

func jump() -> void:
	jump_available = false
	suspension_component.jump()
	physics_manager.jump(slope_jump_mul, spatial_vars.ground_normal)

func _on_physics_manager_apply_force(force: Vector3):
	emit_signal("apply_force", force)

func _on_physics_manager_apply_velocity(velocity: Vector3):
	emit_signal("apply_velocity", velocity)

func _on_suspension_suspension_force(force: Vector3):
	emit_signal("apply_force", force)

func _on_suspension_suspension_velocity(velocity: Vector3):
	emit_signal("apply_velocity", velocity)

func _on_coyote_jump_timer_timeout():
	jump_available = false

func _on_input_manager_jump_pressed():
	if jump_available:
		jump()

func _on_suspension_not_touching_ground(down: Vector3):
	grounded = false
	ground_direction = down

func _on_suspension_touching_ground(down: Vector3):
	grounded = true
	ground_direction = down

func _on_physics_manager_change_gravity(gravity_scale: float):
	emit_signal("change_gravity", gravity_scale)
