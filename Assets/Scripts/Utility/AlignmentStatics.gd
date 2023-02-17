extends Node
class_name AlignmentHelper

func _ready():
	pass

# returns a basis matrix with the x aligned to the vector
func basis_aligned_x(basis_to_align: Basis, vector_to_align_with: Vector3) -> Basis:
	basis_to_align.x = vector_to_align_with
	basis_to_align.y = basis_to_align.z.cross(basis_to_align.y)
	basis_to_align = basis_to_align.orthonormalized()
	return basis_to_align

# returns a basis matrix with the y aligned to the vector
func basis_aligned_y(basis_to_align: Basis, vector_to_align_with: Vector3) -> Basis:
	basis_to_align.y = vector_to_align_with
	basis_to_align.x = -basis_to_align.z.cross(basis_to_align.y)
	basis_to_align = basis_to_align.orthonormalized()
	return basis_to_align

# returns a basis matrix with the z aligned to the vector
func basis_aligned_z(basis_to_align: Basis, vector_to_align_with: Vector3) -> Basis:
	basis_to_align.z = vector_to_align_with
	basis_to_align.x = basis_to_align.y.cross(basis_to_align.z)
	basis_to_align = basis_to_align.orthonormalized()
	return basis_to_align
