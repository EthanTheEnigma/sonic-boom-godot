extends Node3D
class_name MovementStateComponent

@onready @export var movement_forces_component: MovementForcesComponent
@onready @export var suspension_component: SuspensionComponent
@onready @export var coyote_jump_timer: Timer

@onready var controls: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

@export var traction_base: float = 2500
@export var air_control: float = 1250
@export var can_coyote_jump: bool = false
@export var slope_jump_mul: float = 1

var jump_available: bool = true
var has_jumped: bool = false

enum GroundedState {
	GROUND = 0,
	AIR = 1
}

var grounded_state_prev = GroundedState.GROUND
var grounded_state = GroundedState.GROUND

# Called when the node enters the scene tree for the first time.
func _ready():
	coyote_jump_timer.timeout.connect(_on_coyote_jump_timeout.bind())
	controls.jump_pressed.connect(_on_controls_jump_pressed.bind())
	movement_forces_component.slope_jump_mul = slope_jump_mul
	print("ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	grounded_state_prev = grounded_state
	if spatial_vars.grounded == true:
		grounded_state = GroundedState.GROUND
	else:
		grounded_state = GroundedState.AIR
	
	if grounded_state_prev != grounded_state:
		#emit_signal("grounded_state_changed", grounded_state, grounded_state_prev)
		if grounded_state == GroundedState.GROUND:
			jump_available = true
		if grounded_state == GroundedState.AIR:
			coyote_jump_timer.start()
	
	match grounded_state:
		GroundedState.GROUND:
			state_ground()
		GroundedState.AIR:
			state_air()
	
	#print(jump_available)

func state_ground():
	if not controls.is_jump_pressed:
		jump_available = true
		has_jumped = false
	movement_forces_component.traction_base = traction_base
	movement_forces_component.ground_move()

func state_air():
	if can_coyote_jump == false:
		jump_available = false
	movement_forces_component.air_move()
	if has_jumped and not controls.is_jump_pressed:
		movement_forces_component.end_jump()

func jump():
	jump_available = false
	has_jumped = true
	suspension_component.jump()
	movement_forces_component.jump(slope_jump_mul)

func _on_coyote_jump_timeout():
	jump_available = false
	coyote_jump_timer.stop()

func _on_controls_jump_pressed():
	if jump_available:
		jump()
