extends Area3D

@onready var player_body: RigidBody3D = $".."
@onready var rings_manager: RingsManager = $"../RingsManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func deduct_rings():
	pass

func launch_player_hit(launch_direction: Vector3):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
