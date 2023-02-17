extends Node3D
class_name Mouse3rdPersonCam

@onready @export var player_node: Node3D
@onready @export var springarm: SpringArm3D

@onready var controls: GameControls = $"/root/GameControls"
@onready var alignment_funcs: AlignmentStatics = $"/root/AlignmentStatics"
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func cam_input():
	#var cam_input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	if controls.wish_dir_basis.y.y < 0:
		self.rotation.y += controls.cam_input.x * 0.1
	else:
		self.rotation.y -= controls.cam_input.x * 0.1
	springarm.rotation.x -= controls.cam_input.y * 0.1
	springarm.rotation.x = clamp(springarm.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if controls.wish_dir_basis.y.y < 0:
				self.rotate_y(event.relative.x * 0.001)
			else:
				self.rotate_y(-event.relative.x * 0.001)
			
			springarm.rotate_x(-event.relative.y * 0.001)
			springarm.rotation.x = clamp(springarm.rotation.x, deg_to_rad(-80), deg_to_rad(60))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = player_node.position
	position = position + transform.basis.y * 3
	var alignment = alignment_funcs.basis_aligned_y(transform.basis, controls.ground_normal)
	transform.basis = transform.basis.slerp(alignment, 0.2)
	cam_input()
	controls.wish_dir_basis = transform.basis
