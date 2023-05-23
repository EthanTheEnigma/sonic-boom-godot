extends Node3D
class_name Mouse3rdPersonCam

@export var player_node_path: Node3D
@export var springarm_path: SpringArm3D

@onready var player_node: Node3D = player_node_path
@onready var springarm: SpringArm3D = $"SpringArm3D"

@onready var controls: GameControls = $"/root/GameControls"
@onready var alignment_funcs: AlignmentStatics = $"/root/AlignmentStatics"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

var up_axis: Vector3 = Vector3.UP
var right_axis: Vector3 = Vector3.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func cam_input():
	self.transform.basis = self.transform.basis.rotated(up_axis, -controls.cam_input.x * 0.1)
	springarm.rotation.x -= controls.cam_input.y * 0.1
	springarm.rotation.x = clamp(springarm.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			self.transform.basis = self.transform.basis.rotated(up_axis, -event.relative.x * 0.001)
			springarm.rotation.x = clamp(springarm.rotation.x, deg_to_rad(-80), deg_to_rad(60))
			springarm.rotate_x(-event.relative.y * 0.001)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	up_axis = self.transform.basis.y
	right_axis = self.transform.basis.x
	position = player_node.position
	position = position + transform.basis.y * 3
	var alignment = alignment_funcs.basis_aligned_y(transform.basis, controls.ground_normal)
	transform.basis = transform.basis.slerp(alignment, 0.2)
	cam_input()
	controls.wish_dir_basis = transform.basis
