extends KinematicBody

export var speed = 2
export var damage = 3
export var health = 1

var isAggro = false

var player = null
var nav = null
var path = []

onready var sprite_manager = $AnimatedSprite3D

onready var explosion_prefab = preload("res://prefabs/explosion.tscn")

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	nav = get_node("/root/Scene/Navigation")

func _physics_process(delta):
	if health <= 0:
		return
	
	check_player()
	
	var d = global_transform.origin.distance_to(player.global_transform.origin)
	if d < 2.0:
		explode()
	
	if !isAggro:
		return
	
	#https://github.com/Miziziziz/Thine-Shooteth/blob/master/characters/BigBrain.gd
	var path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	if path.size() > 0 and health >= 1:
		var dir = global_transform.origin.direction_to(path[1])
		dir.y = 0
		move_and_collide(dir.normalized() * speed * delta)
		$AnimatedSprite3D.play("walk")
	else:
		$AnimatedSprite3D.play("idle")
		
	move_and_slide(Vector3.DOWN * 98 * delta);

func check_player():
	var distance = (global_transform.origin - player.global_transform.origin).length()
	var state = get_world().direct_space_state
	var result = state.intersect_ray(global_transform.origin, player.global_transform.origin)
	if !result or result.collider.name == "Player":
		isAggro = true
		
func damage(damage):
	sprite_manager.play("hit")
	health -= damage
	check_health()

func explode():
	var e = explosion_prefab.instance()
	e.global_transform = global_transform
	get_tree().get_root().add_child(e)
	
	var bodies = $Area.get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("damage"):
			body.damage(damage)
		elif body.name == "Player":
			body.health -= damage
	
func check_health():
	if health <= 0:
		sprite_manager.play("dead")
		#queue_free()
