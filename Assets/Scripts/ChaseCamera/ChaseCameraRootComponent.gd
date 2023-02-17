extends CharacterBody3D
class_name ChaseCameraRootComponent

@onready var controls: Controls = $"/root/GameControls"
@onready var alignment_funcs: AlignmentHelper = $"/root/AlignmentStatics"
@onready @export var player_body: Node3D

var cam_springarm_distance: float = 10
var cam_springarm_damping: float = 100
var cam_springarm_strength: float = 5000
var cam_rotate_speed: float = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var player_vector_normal = ( position - (player_body.position - controls.ground_normal * 2) ).normalized()
	var alignment = alignment_funcs.basis_aligned_y(transform.basis, controls.ground_normal)
	transform.basis = transform.basis.slerp(alignment, 0.2)
	alignment = alignment_funcs.basis_aligned_z(transform.basis, player_vector_normal)
	transform.basis = transform.basis.slerp(alignment, 0.8)
	up_direction = -controls.ground_normal
	var cam_distance_current = position.distance_to(player_body.position)
	var offset = cam_springarm_distance - cam_distance_current
	var springarm_force = offset * cam_springarm_strength
	velocity = (transform.looking_at(player_body.position + (controls.ground_normal * 2), Vector3(0, 1, 0)).basis.z * springarm_force) * delta
	controls.wish_dir_basis = transform.basis
	velocity += (transform.basis.x * controls.cam_input.x) * cam_rotate_speed
	velocity += (transform.basis.y * controls.cam_input.y) * cam_rotate_speed
	move_and_slide()
