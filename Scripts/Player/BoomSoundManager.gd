extends Node3D

enum MovementState {
	NORMAL = 0,
	ROLL = 1,
	BOOST = 2
}

##@export var boost_sound_path: AudioStreamPlayer
##@export var wind_sound_path: AudioStreamPlayer
##@export var roll_sound_path: AudioStreamPlayer

@onready var boost_sound: AudioStreamPlayer = $"../BoostSoundPlayer"
@onready var wind_sound: AudioStreamPlayer = $"../WindSoundPlayer"
@onready var roll_sound: AudioStreamPlayer = $"../RollSoundPlayer"

@onready var hud_vars: HUDStatics = $"/root/HudStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	wind_sound.volume_db = -120
	wind_sound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	wind_sound.volume_db = clampf(hud_vars.current_speed - 40, -40, 10)
	wind_sound.pitch_scale = clampf((hud_vars.current_speed + 1)/60, 1, 4)


func _on_boom_movement_state_component_move_state_changed(move_state, move_state_prev):
	match move_state:
		MovementState.NORMAL:
			return
		MovementState.ROLL:
			roll_sound.play()
		MovementState.BOOST:
			boost_sound.play()
