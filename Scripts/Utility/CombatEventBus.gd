extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func register_hitbox(hitbox: HitboxTest):
	print(str("registering: " + str(hitbox)))
	hitbox.area_entered.connect(_on_attack_land)
	print(hitbox.area_entered.get_connections())

func _on_attack_land(area: Area3D):
	area as SonicHurtbox
	if not area:
		print("hurtbox not found")
		return
	area.launch_player_hit(Vector3(0, 50, 0))
