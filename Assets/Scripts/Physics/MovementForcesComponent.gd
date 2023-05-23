extends Node
class_name MovementForcesComponent

@onready var controls: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"
@onready var hud_vars: HUDStatics = $"/root/HudStatics"
@export var jump_allowed: bool = true
@onready var player_body: RigidBody3D = $".."
@onready var suspension_component: SuspensionComponent = $"../SuspensionComponent"

# These can be modified by a MovementStateComponent, or used on their own
var drag_coefficient: float = 0.4
var drag_area: float = 0.5
var air_density: float = 1.225
var traction_base: float = 2500
var air_control: float = 1250
var top_speed_base: float = 30
var slope_accel_multiplier: float = 0
var slope_jump_mul: float = 1
var jump_force_base: float = 32
var accel: float = 300
var downforce_mul: float = 0.8
# for the love of all that is holy do not set this to 0
var friction: float = 100

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
var air_moving: bool = false

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
	accel_curve_point = clampf(ground_plane_speed, 1, top_speed_base) / top_speed_base
	slip_angle_degrees = rad_to_deg(acos(slip_angle_scalar))
	if spatial_vars.grounded:
		hud_vars.current_speed = player_body.get_linear_velocity().length()
	else:
		hud_vars.current_speed = \
			( player_body.get_linear_velocity() * Vector3(1, 0, 1) ).length()

func apply_accel(top_speed: float, acceleration: float, slope_mul: float, mask_direction: Vector3) -> void:
	if controls.wish_dir.length() > 0:
		player_body.linear_damp = 0
	else:
		player_body.linear_damp = 0.25
	top_speed *= 1 + (Vector3(0, -1, 0).dot(controls.wish_dir) * slope_mul)
	if player_body.get_linear_velocity().length() < top_speed:
		acceleration *= 1 + (Vector3(0, -1, 0).dot(controls.wish_dir) * slope_mul)
		player_body.apply_central_force(controls.wish_dir * acceleration)
	else:
		if controls.wish_dir.length() > 0:
			# mass divided by 10 here is just a magic number I found in testing.
			# friction is just a value I use to determine how much momentum is preserved
			# drag will be a better term
			# but I'm gonna wait until I refactor because it's still in use for another thing rn
			player_body.apply_central_force(\
				player_body.get_linear_velocity().normalized() * \
				( player_body.get_linear_velocity().length() * (player_body.mass / 10) ) \
				* 1/friction )
		# this is so slopes can still affect player movement even if over top speed
		player_body.apply_central_force(\
			player_body.get_linear_velocity().normalized() * \
			( (Vector3(0, -1, 0)\
				.dot(player_body.get_linear_velocity().normalized() * mask_direction) \
				* slope_mul) * accel ) )

func apply_grip(compensation: bool, traction: float, mask_direction: Vector3) -> void:
	var slippage = (slip_angle_scalar + 1) * (slip_angle_scalar + 1)
	# grip is traction after adding all the modifiers
	# consider traction to be like a raw value
	# never used directly but modified based on external variables before use
	var grip = traction
	grip *= ( -0.125 * ( slippage * slippage ) + (0.75 * slippage) )
	grip += 0.25 * traction
	# this is so the player has higher grip at higher speeds
	# there seems to be no ideal single value
	# so we increase grip based on velocity
	grip *= clampf(player_body.get_linear_velocity().length(), 1, 400) / 50
	if slip_angle_scalar != 1 && controls.wish_dir.length() > 0:
		var correction_dir = \
			controls.wish_dir.normalized() - \
			( player_body.get_linear_velocity() * mask_direction ).normalized()
		player_body.apply_central_force(correction_dir * grip)
		if compensation:
			player_body\
				.apply_central_force(controls.wish_dir.normalized() * \
				(controls.wish_dir.normalized().dot(correction_dir) * grip))

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
		jump_force_base * \
		(1 + (Vector3(0, 1, 0).dot(controls.wish_dir) * slope_mul) ), \
		jump_force_base, \
		jump_force_base * 6 )
	print(jump_force)
	player_body.set_axis_velocity(spatial_vars.ground_normal * jump_force)

func end_jump() -> void:
	pass
	#if player_body.get_linear_velocity().y > jump_force_base / 2:
		#player_body.set_axis_velocity(Vector3.UP * player_body.get_linear_velocity().y * 0.75)

func launch(velocity: Vector3) -> void:
	player_body.set_axis_velocity(velocity)

func ground_move() -> void:
	air_moving = false
	player_body.set_gravity_scale(0)
	ground_plane_speed = total_speed
	slip_angle_scalar = \
		player_body.get_linear_velocity().normalized().dot(controls.wish_dir)
	
	apply_accel(top_speed_base, accel, slope_accel_multiplier, Vector3(1, 1, 1))
	apply_grip(true, traction_base, Vector3(1, 1, 1))
	#apply_drag(drag, Vector3(1, 1, 1))

func air_move() -> void:
	air_moving = true
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
	
	
	apply_accel(top_speed_base, accel, slope_accel_multiplier, Vector3(1, 0, 1))
	apply_grip(true, air_control, Vector3(1, 0, 1))
	#apply_drag(drag, Vector3(1, 0, 1))
	
	if player_body.get_linear_velocity().dot(ground_direction) < 0:
		player_body.apply_central_force(ground_direction * downforce)

func _physics_process(delta):
	update_global_movement_vars()


func _on_player_body_entered(body):
	# let's just hope that this function always gives me a physics body ¯\_(ツ)_/¯
	var colliding_phys_body: PhysicsBody3D = body
	var suspension_target: Vector3 = (self.global_position - (self.global_position + colliding_phys_body.global_position) ).normalized()
	suspension_component.target_position = suspension_target
