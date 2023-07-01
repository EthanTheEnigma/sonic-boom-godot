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

func register_ring_hitbox(hitbox: Ring):
	print(str("registering: " + str(hitbox)))
	hitbox.area_entered.connect(_on_ring_connect)

func _on_attack_land(area: Area3D):
	area as SonicHurtbox
	if not area:
		print("hurtbox not found")
		return
	area.launch_player_hit(Vector3(0, 50, 0))
	area.deduct_rings()

func _on_ring_connect(area: Area3D):
	area as SonicHurtbox
	if not area:
		print("hurtbox not found")
		return
	area.add_rings()
