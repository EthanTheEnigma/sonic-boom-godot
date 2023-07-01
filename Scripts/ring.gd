extends Area3D
class_name Ring

@onready var col_event: CombatEventBus = $"/root/CombatEventBus"

# Called when the node enters the scene tree for the first time.
func _ready():
	col_event.register_ring_hitbox(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in get_overlapping_areas():
		emit_signal("area_entered")
		queue_free()
