extends Control
class_name DebugUI

@onready var character: BoomCharacterController = $".."
@onready var physics_manager: PhysicsManager = $"../PhysicsManager"
@onready var suspension: RayCast3D = $"../Suspension"
@onready var speed_label := $DebugLabelBox/SpeedLabel
@onready var slip_label := $DebugLabelBox/SlipLabel
@onready var grip_label := $DebugLabelBox/GripLabel
@onready var ground_normal_label := $DebugLabelBox/GroundNormalLabel
@onready var heat_label := $DebugLabelBox/HeatLabel
@onready var drag_label := $DebugLabelBox/DragLabel
@onready var suspension_label := $DebugLabelBox/SuspensionLabel
@onready var wish_dir_label := $DebugLabelBox/WishDirLabel
@onready var ground_plane_label := $DebugLabelBox/GroundPlaneLabel
@onready var accel_label := $DebugLabelBox/AccelerationLabel
@onready var boost_bar := $BoostBox/BoostBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func manage_debug_hud():
	speed_label.text = "Speed: " + str(ceil(physics_manager.ground_plane_speed))
	drag_label.text = "Aero Drag: " + str(ceil(physics_manager.drag))
	slip_label.text = "Slip Angle: " + str(ceil(physics_manager.slip_angle_degrees))
	ground_normal_label.text = "Ground Normal: " + str(suspension.get_collision_normal())
	wish_dir_label.text = "Input Direction: " + str(physics_manager.wish_dir)
	var sprint_percent = clampf(character.current_boost_energy, 1, character.max_boost_energy) / character.max_boost_energy
	boost_bar.value = sprint_percent
	if !character.can_boost:
		boost_bar.visible = false
	else:
		boost_bar.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	manage_debug_hud()
