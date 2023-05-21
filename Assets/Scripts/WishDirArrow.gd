extends Node3D

@onready var player_body: RigidBody3D = $".."
@onready var controls: GameControls = $"/root/GameControls"
@onready var alignment_statics: AlignmentStatics = $"/root/AlignmentStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if controls.wish_dir.length() > 0.25:
		var alignment = transform\
		.basis\
		.looking_at(position - (position - controls.wish_dir.normalized() * 3))
		self.transform.basis = transform.basis.slerp(alignment, 0.4)
	else:
		self.transform = transform.looking_at(position - (position - player_body.get_linear_velocity().normalized() * 3))
	
