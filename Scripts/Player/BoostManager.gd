extends Node3D
class_name BoostManager

@onready var input_manager: Controls = $"/root/GameControls"
@onready var hud_vars: HUDStatics = $"/root/HudStatics"
##@export var movement_state_component_path: BoomMovementStateComponent
@export var max_boost_energy: float = 480

@onready var movement_state_component: BoomMovementStateComponent = $"../BoomMovementStateComponent"

var current_boost_energy: float = max_boost_energy

func decrement_boost():
	if current_boost_energy == 0:
		movement_state_component.can_boost = false
		hud_vars.boost_available = false
	if current_boost_energy > 0 and movement_state_component.can_boost:
		current_boost_energy -= 1

func just_boosted():
	if movement_state_component.can_boost:
		if current_boost_energy > 60:
			current_boost_energy -= 60
		else:
			current_boost_energy -= current_boost_energy
	

func increment_boost():
	if current_boost_energy < max_boost_energy:
		current_boost_energy += 1
	if current_boost_energy == max_boost_energy:
		movement_state_component.can_boost = true
		hud_vars.boost_available = true

# Called when the node enters the scene tree for the first time.
func _ready():
	hud_vars.boost_max = max_boost_energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	hud_vars.boost_energy = current_boost_energy
	#print(current_boost_energy)
