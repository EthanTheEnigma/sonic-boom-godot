extends Node3D
class_name AlignedNode

@export var align_with_input_direction: bool = false
@export var interp_speed: float = 0.2

@onready var alignment_funcs: AlignmentHelper = $"/root/AlignmentStatics"
@onready var input_manager: Controls = $"/root/GameControls"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if spatial_vars.grounded:
		var alignment = alignment_funcs.basis_aligned_y(transform.basis, spatial_vars.ground_normal)
		transform = transform.interpolate_with(alignment, interp_speed)
	else:
		var alignment = alignment_funcs.basis_aligned_y(transform.basis, Vector3(0, 1, 0))
		transform = transform.interpolate_with(alignment, interp_speed)
	
	if align_with_input_direction:
		var rotation_basis = input_manager.wish_dir_basis * Vector3(input_manager.input_dir.x, 0, input_manager.input_dir.y)
		rotation.y = Vector2(-rotation_basis.z, -rotation_basis.x).angle()
