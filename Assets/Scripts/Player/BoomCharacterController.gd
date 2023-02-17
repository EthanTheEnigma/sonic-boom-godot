extends RigidBody3D

@onready var hud_vars: HUDStatics = $"/root/HudStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	#hud_vars.current_speed = linear_velocity.length()
