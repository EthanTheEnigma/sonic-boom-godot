extends Control
class_name BoomHUDComponent

@onready var hud_vars: HUDStatics = $"/root/HudStatics"
@onready var boost_bar = $BoostBox/BoostBar
@onready var speedometer = $HBoxContainer/Speedometer
@onready var boost_container = $BoostBox

# Called when the node enters the scene tree for the first time.
func _ready():
	boost_bar.max_value = hud_vars.boost_max


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	boost_bar.value = hud_vars.boost_energy
	if not hud_vars.boost_available:
		boost_container.hide()
	else:
		boost_container.show()
	speedometer.value = hud_vars.current_speed
