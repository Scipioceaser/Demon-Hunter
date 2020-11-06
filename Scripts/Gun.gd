extends RayCast

onready var rocket_prefab = preload("res://prefabs/rocket.tscn")

export var fire_range = 15.0
export var damage = 2
export var fire_count = 1
export var rocket_speed = 120.0

var const_cast = null

var ammo_count = 1

func _ready():
	const_cast = cast_to

func fire():
	cast_to = const_cast * fire_range
	if fire_count == 1:
		emit_bullet()
	else:
		for i in fire_count:
			emit_bullet(Vector3(rand_range(-0.15, .15), rand_range(-0.15, .15), rand_range(-0.15, .15)))

func fire_rocket(rocket_spawn):
	var rocket = rocket_prefab.instance()
	get_tree().get_root().add_child(rocket)
	rocket.global_transform = rocket_spawn.global_transform
	rocket.speed = rocket_speed
	rocket.damage = damage
	rocket.apply_central_impulse(-global_transform.basis.z * rocket_speed)

	
func emit_bullet(offset=Vector3(0, 0, 0)):
	rotation = offset
	if is_colliding():
		if get_collider().name == "Player":
			return
		elif get_collider().has_method("damage"):
			get_collider().damage(damage)
		else:
			pass
			#Create decal
	force_raycast_update()
