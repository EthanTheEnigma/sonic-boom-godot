extends Camera3D
class_name ChaseCameraLookAtComponent

@onready @export var look_at_node: Node3D

@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spatial_vars.grounded:
		look_at(look_at_node.position, spatial_vars.ground_normal)
	else:
		look_at(look_at_node.position, Vector3.UP)
