extends Node3D
class_name PhysicsManager

# The physics manager calculates forces for grounded and aerial movement

@onready @export var accel_curve: Curve
@export var jump_allowed: bool = true

# these are variables that are set by the player controller
var drag_coefficient: float = 0.4
var drag_area: float = 0.5
var air_density: float = 1.225
var base_traction: float = 2200
var top_speed: float = 30
var slope_accel_multiplier: float = 0
var slope_jump_mul: float = 1
var base_jump_force: float = 16
var accel: float = 200
var downforce_mul: float = 0.8

@onready var input_manager: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

# these are variables whose values fluctuate on player input
var slip_angle_scalar: float = 0
var slip_angle_degrees: float = 0
var total_speed: float = 0
var ground_plane_speed: float = 0
var movement_resistance: float = 0
var drag: float = 0
var accel_curve_point: float = 0
var downforce: float = 0
var velocity: Vector3 = Vector3.ZERO
var ground_direction: Vector3 = Vector3.ZERO
var force_direction: Vector3 = Vector3.ZERO
var launch_direction: Vector3 = Vector3.ZERO

signal apply_force
signal apply_velocity
signal change_gravity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_global_movement_vars() -> void:
	total_speed = velocity.length()
	movement_resistance = total_speed * 2 + 100
	drag = drag_coefficient * ( air_density * ( (total_speed * total_speed) / 2 ) * drag_area )
	accel_curve_point = clampf(ground_plane_speed, 1, top_speed) / top_speed
	slip_angle_degrees = rad_to_deg(acos(slip_angle_scalar))

func apply_accel(acceleration: float, slope_mul: float) -> void:
	acceleration *= 1 + (Vector3(0, -1, 0).dot(input_manager.wish_dir) * slope_mul)
	acceleration *= accel_curve.sample(accel_curve_point)
	emit_signal("apply_force", input_manager.wish_dir * acceleration)

func apply_grip(traction: float, mask_direction: Vector3) -> void:
	var slippage = (slip_angle_scalar + 1) * (slip_angle_scalar + 1)
	traction *= ( -0.125 * ( slippage * slippage ) + (0.75 * slippage) )
	traction += 0.25 * base_traction
	if slip_angle_scalar != 1 && input_manager.wish_dir.length() > 0:
		var correction_dir = input_manager.wish_dir.normalized() - ( velocity * mask_direction ).normalized()
		emit_signal("apply_force", correction_dir * traction)

func apply_drag(current_drag: float, mask_direction: Vector3) -> void:
	emit_signal("apply_force", -((velocity.normalized() * mask_direction.normalized()) * current_drag))
	if input_manager.wish_dir.length() == 0:
		emit_signal("apply_force", -((velocity.normalized() * mask_direction.normalized()) * movement_resistance))

func jump(mul: float, jump_direction: Vector3) -> void:
	var jump_force = clampf( base_jump_force * (1 + (Vector3(0, 1, 0).dot(input_manager.wish_dir) * mul) ), base_jump_force, base_jump_force * 6 )
	emit_signal("apply_velocity", jump_direction * jump_force)

func ground_move() -> void:
	emit_signal("change_gravity", 0)
	ground_plane_speed = total_speed
	slip_angle_scalar = velocity.normalized().dot(input_manager.wish_dir)
	
	apply_accel(accel, slope_accel_multiplier)
	apply_grip(base_traction, Vector3(1, 1, 1))
	apply_drag(drag, Vector3(1, 1, 1))

func launch(velocity: Vector3) -> void:
	emit_signal("apply_velocity", velocity)

func air_move() -> void:
	emit_signal("change_gravity", 1)
	ground_plane_speed = (velocity * Vector3(1, 0, 1)).length()
	slip_angle_scalar = (velocity * Vector3(1, 0, 1)).normalized().dot(input_manager.wish_dir)
	downforce = drag * downforce_mul
	
	if Input.is_action_pressed("jump"):
		emit_signal("change_gravity", 0.5)
	else:
		emit_signal("change_gravity", 1)
	
	apply_accel(accel, slope_accel_multiplier)
	apply_grip(base_traction, Vector3(1, 0, 1))
	apply_drag(drag, Vector3(1, 0, 1))
	
	if velocity.dot(ground_direction) < 0:
		emit_signal("apply_force", ground_direction * downforce)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_global_movement_vars()
