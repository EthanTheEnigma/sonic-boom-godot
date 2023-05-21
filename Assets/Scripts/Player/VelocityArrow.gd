extends Node3D

@onready var player_body: RigidBody3D = $".."
@onready var spatial_vars: SpatialVarStatics = $"/root/SpatialVarStatics"
@onready var alignment_statics: AlignmentStatics = $"/root/AlignmentStatics"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.transform = transform.looking_at(position - (position - player_body.get_linear_velocity().normalized() * 3))
