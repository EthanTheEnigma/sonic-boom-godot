extends RayCast3D

@onready var player_body: RigidBody3D = $".."

@onready var movement_forces_component: MovementForcesComponent = $"../MovementForcesComponent"

@onready var controls: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func manage_wall() -> Vector3:
	target_position = controls.wish_dir
	return get_collision_normal()

func clip_wall() -> void:
	var wall_normal = manage_wall()
	if is_colliding() and movement_forces_component.air_moving:
		var backoff = player_body.get_linear_velocity().dot(wall_normal)
		player_body.set_axis_velocity(player_body.get_linear_velocity() - (wall_normal * 1.25 * backoff ))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	clip_wall()
