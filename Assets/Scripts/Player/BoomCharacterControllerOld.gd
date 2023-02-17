extends RigidBody3D
class_name BoomCharacterControllerOld

# LICENSED UNDER MIT

# This script goes at the root of your character's scene tree
# This script expects, at the very least:
# - Collision, because it inherits from Rigidbody
# - A character mesh, cause it rotates the character mesh
# - A node that is the root of a spring arm and camera, here caled "spring_arm_attach"
# - A timer for coyote jumping
# - A Raycast3D for the suspension, although this script only uses it for getting ground normals
# THIS IS VERY SUBJECT TO CHANGE AS I'M REFACTORING FOR READABILITY, SCALABILITY, AND EASE OF MODIFICATION
# I WANT TO EVENTUALLY DECOUPLE THIS A BIT MORE

@onready @export var spring_arm_attach: Node3D = $SpringArmAttachment
@onready @export var spring_arm: SpringArm3D = $SpringArmAttachment/SpringArm3D
@onready @export var boost_sound := $BoostSoundPlayer
@onready @export var wind_sound := $WindSoundPlayer
@onready @export var roll_sound := $RollSoundPlayer
@export var max_boost_energy: float = 240

@onready var controls: Controls = $"/root/GameControls"

enum GroundedState {
	GROUND = 0,
	AIR = 1,
	CUSTOM = 2
}
enum MovementState {
	NORMAL = 0,
	ROLL = 1,
	BOOST = 2
}

var ground_state = GroundedState.GROUND
var current_boost_energy: float = max_boost_energy
var can_boost: bool = true
var is_boosting: bool = false
var boost_available: bool = true

@onready var movement_component: MovementComponent = $MovementComponent
@onready var boost_manager: BoostManager = $BoostManager

# Called when the node enters the scene tree for the first time.
func _ready():
	wind_sound.play()
	wind_sound.volume_db = -80

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if controls.wish_dir_basis.y.y < 0:
				spring_arm_attach.rotate_y(event.relative.x * 0.001)
			else:
				spring_arm_attach.rotate_y(-event.relative.x * 0.001)
			
			spring_arm.rotate_x(-event.relative.y * 0.001)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func camera_input() -> void:
	var cam_input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	if controls.wish_dir_basis.y.y < 0:
		spring_arm_attach.rotation.y += cam_input.x * 0.1
	else:
		spring_arm_attach.rotation.y -= cam_input.x * 0.1
	spring_arm.rotation.x -= cam_input.y * 0.1
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func update_global_movement_vars() -> void:
	movement_component.velocity = linear_velocity

func _physics_process(delta):
	if movement_component.move_state == MovementState.BOOST:
		boost_manager.decrement_boost()
	else:
		boost_manager.increment_boost()
	update_global_movement_vars()
	camera_input()


func _on_movement_component_apply_force(force: Vector3):
	apply_central_force(force)

func _on_movement_component_apply_velocity(velocity: Vector3):
	set_axis_velocity(velocity)

func _on_movement_component_grounded_state_changed(state: int, state_prev: int):
	ground_state = state


func _on_movement_component_change_gravity(gravity: float):
	gravity_scale = gravity

func _on_movement_component_move_state_changed(state: int, state_prev: int):
	if state == MovementState.BOOST:
		boost_sound.play()
	if state == MovementState.ROLL:
		roll_sound.play()
