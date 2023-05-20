extends RayCast3D
class_name SuspensionComponent

# Licensed under MIT

# This class is responsible for providing suspension for the Rigidbody

##@export var suspension_model_path: MeshInstance3D
##@export var player_body_path: RigidBody3D

@onready var suspension_model: MeshInstance3D = $"SuspensionModel"
@onready var player_body: RigidBody3D = $".."
@export var suspension_strength: float = 12000
@export var suspension_damping: float = 600
@export var downforce_mul: float = 0.8
@export var suspension_length: float = 2
@export var ride_height: float = 1.25
@export var allow_jumping: bool = true

@onready var controls: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

var ground_direction: Vector3 = -Vector3.UP
var velocity: Vector3 = Vector3.ZERO

signal suspension_force
signal suspension_velocity
signal touching_ground
signal not_touching_ground

func manage_ground() -> Vector3:
	target_position = -get_collision_normal() * suspension_length
	return -get_collision_normal()

func ground_suspension() -> void:
	var ground_normal = -manage_ground()
	var current_ride_height: float = global_position.distance_to(get_collision_point())
	var suspension_offset = ride_height - current_ride_height
	var suspension_force = 0
	suspension_force = suspension_offset * suspension_strength
	suspension_force -= player_body.get_linear_velocity().dot(get_collision_normal()) * suspension_damping
	
	if is_colliding:
		controls.ground_normal = ground_normal
		spatial_vars.ground_normal = ground_normal
	
	suspension_model.position = position - (get_collision_normal() * (current_ride_height * 0.75) )
	player_body.apply_central_force(ground_normal * suspension_force)
	
	if current_ride_height < 1:
		player_body.set_axis_velocity(ground_normal * 1)
	if current_ride_height > 1.5:
		player_body.set_axis_velocity(-ground_normal * 1)

func jump() -> void:
	#this is just to keep the player from being stuck to the ground from the suspension
	target_position = Vector3(0, 1, 0)

func air() -> void:
	target_position = Vector3(0, -1, 0) * (suspension_length * 0.5)
	suspension_model.position = position - (position + Vector3(0, 0.5, 0))
	ground_direction = Vector3(0, -1, 0)
	controls.ground_normal = Vector3(0, 1, 0)

func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if is_colliding():
		emit_signal("touching_ground", -get_collision_normal())
		spatial_vars.grounded = true
		if not Input.is_action_pressed("jump"):
			ground_suspension()
	else:
		emit_signal("not_touching_ground", Vector3(0, -1, 0))
		spatial_vars.grounded = false
		air()
