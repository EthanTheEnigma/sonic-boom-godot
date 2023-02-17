extends Node
class_name MovementForcesComponent

@onready var controls: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"
@onready var hud_vars: HUDStatics = $"/root/HudStatics"
@onready @export var player_body: RigidBody3D
@onready @export var accel_curve: Curve
@export var jump_allowed: bool = true

# These can be modified by a MovementStateComponent, or used on their own
var drag_coefficient: float = 0.4
var drag_area: float = 0.5
var air_density: float = 1.225
var traction_base: float = 2500
var air_control: float = 1250
var top_speed: float = 30
var slope_accel_multiplier: float = 0
var slope_jump_mul: float = 1
var jump_force_base: float = 32
var accel: float = 200
var downforce_mul: float = 0.8

# these are variables whose values fluctuate on player input
var slip_angle_scalar: float = 0
var slip_angle_degrees: float = 0
var total_speed: float = 0
var ground_plane_speed: float = 0
var movement_resistance: float = 0
var drag: float = 0
var accel_curve_point: float = 0
var downforce: float = 0
var ground_direction: Vector3 = Vector3(0, -1, 0)
var force_direction: Vector3 = Vector3.ZERO
var launch_direction: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_global_movement_vars() -> void:
	total_speed = player_body.get_linear_velocity().length()
	movement_resistance = total_speed * 2 + 100
	drag = \
		drag_coefficient * ( air_density * \
		( (total_speed * total_speed) / 2 ) * \
		drag_area )
	accel_curve_point = clampf(ground_plane_speed, 1, top_speed) / top_speed
	slip_angle_degrees = rad_to_deg(acos(slip_angle_scalar))
	if spatial_vars.grounded:
		hud_vars.current_speed = player_body.get_linear_velocity().length()
	else:
		hud_vars.current_speed = \
			( player_body.get_linear_velocity() * Vector3(1, 0, 1) ).length()

func apply_accel(acceleration: float, slope_mul: float) -> void:
	acceleration *= 1 + (Vector3(0, -1, 0).dot(controls.wish_dir) * slope_mul)
	acceleration *= accel_curve.sample(accel_curve_point)
	player_body.apply_central_force(controls.wish_dir * acceleration)

func apply_grip(traction: float, mask_direction: Vector3) -> void:
	var slippage = (slip_angle_scalar + 1) * (slip_angle_scalar + 1)
	# grip is traction after adding all the modifiers
	# consider traction to be like a raw value
	# never used directly but modified based on external variables before use
	var grip = traction
	grip *= ( -0.125 * ( slippage * slippage ) + (0.75 * slippage) )
	grip += 0.25 * traction
	if slip_angle_scalar != 1 && controls.wish_dir.length() > 0:
		var correction_dir = \
			controls.wish_dir.normalized() - \
			( player_body.get_linear_velocity() * mask_direction ).normalized()
		player_body.apply_central_force(correction_dir * grip)

func apply_drag(current_drag: float, mask_direction: Vector3) -> void:
	player_body.apply_central_force( \
		-((player_body.get_linear_velocity().normalized() * \
		mask_direction.normalized()) * \
		current_drag))
	if controls.wish_dir.length() == 0:
		player_body.apply_central_force( \
			-( (player_body.get_linear_velocity().normalized() * \
			mask_direction.normalized()) * \
			movement_resistance))

func jump(slope_mul: float) -> void:
	var jump_force = clampf( \
		jump_force_base * (1 + (Vector3(0, 1, 0).dot(controls.wish_dir) * slope_mul) ), \
		jump_force_base, \
		jump_force_base * 6 )
	print(jump_force)
	player_body.set_axis_velocity(spatial_vars.ground_normal * jump_force)

func end_jump() -> void:
	if player_body.get_linear_velocity().y > jump_force_base / 2:
		player_body.set_axis_velocity(Vector3.UP * jump_force_base / 2)

func launch(velocity: Vector3) -> void:
	player_body.set_axis_velocity(velocity)

func ground_move() -> void:
	player_body.set_gravity_scale(0)
	ground_plane_speed = total_speed
	slip_angle_scalar = \
		player_body.get_linear_velocity().normalized().dot(controls.wish_dir)
	
	apply_accel(accel, slope_accel_multiplier)
	apply_grip(traction_base, Vector3(1, 1, 1))
	apply_drag(drag, Vector3(1, 1, 1))

func air_move() -> void:
	if Input.is_action_pressed("jump"):
		player_body.set_gravity_scale(0.75)
	else:
		player_body.set_gravity_scale(1)
	ground_plane_speed = \
		(player_body.get_linear_velocity() * Vector3(1, 0, 1)).length()
	slip_angle_scalar = \
		(player_body.get_linear_velocity() * \
		Vector3(1, 0, 1)).normalized().dot(controls.wish_dir)
	downforce = drag * downforce_mul
	
	
	apply_accel(accel, slope_accel_multiplier)
	apply_grip(air_control, Vector3(1, 0, 1))
	apply_drag(drag, Vector3(1, 0, 1))
	
	if player_body.get_linear_velocity().dot(ground_direction) < 0:
		player_body.apply_central_force(ground_direction * downforce)

func _physics_process(delta):
	update_global_movement_vars()
