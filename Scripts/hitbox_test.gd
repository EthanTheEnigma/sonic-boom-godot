extends Area3D
class_name HitboxTest

@onready var col_event: CombatEventBus = $"/root/CombatEventBus"

# Called when the node enters the scene tree for the first time.
func _ready():
	col_event.register_hitbox(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# I don't know why, I don't want to know why, I shouldn't have to wonder why,
	# but for whatever reason this builtin signal isn't emitting correctly unless
	# we do this terribleness
	# lol
	for i in get_overlapping_areas():
		emit_signal("area_entered")

