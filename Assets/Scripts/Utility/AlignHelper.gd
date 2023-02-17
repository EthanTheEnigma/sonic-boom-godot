extends Node3D
class_name AlignHelper

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func align_with_normal(input_basis: Basis, normal: Vector3) -> Basis:
	input_basis.y = normal
	input_basis.x = -input_basis.z.cross(input_basis.y)
	input_basis = input_basis.orthonormalized()
	return input_basis

func z_aligned_with_normalized_vector(input_basis: Basis, vector: Vector3) -> Basis:
	input_basis.z = vector
	input_basis.x = input_basis.y.cross(input_basis.z)
	input_basis = input_basis.orthonormalized()
	return input_basis

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
