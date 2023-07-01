extends Area3D
class_name SonicHurtbox

@onready var player_body: RigidBody3D = $".."
@onready var rings_manager: RingsManager = $"../RingsManager"
@onready var suspension: SuspensionComponent = $"../SuspensionComponent"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func deduct_rings():
	print("expel rings")
	rings_manager.expel_rings()

func add_rings():
	print("add ring")
	rings_manager.increment_rings()

func launch_player_hit(launch_direction: Vector3):
	print("launching player")
	print(launch_direction)
	suspension.jump()
	player_body.set_axis_velocity(-player_body.get_linear_velocity())
	player_body.set_axis_velocity(launch_direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
