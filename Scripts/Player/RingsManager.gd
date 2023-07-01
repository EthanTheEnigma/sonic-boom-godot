extends Node3D
class_name RingsManager

var rings: int = 0
@onready var hud_vars: HUDStatics = $"/root/HudStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func expel_rings():
	rings = 0
	hud_vars.rings = rings

func increment_rings():
	rings += 1
	hud_vars.rings = rings

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
