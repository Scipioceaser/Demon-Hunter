extends KinematicBody

#TODO: Touch up movement and add shooting

export var speed = 1.5
export var shotgun_spread = 4
export var damage = 1
export var health = 2
export var weapon_range = 8

export var aggression = 2

var isAggro = false

var player = null
var path = []
var nav = null

var begin = Vector3()
var end = Vector3()
var player_old_position = Vector3()

onready var sprite_manager = $AnimatedSprite3D

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	nav = get_node("/root/Scene/Navigation")

var last_time_since_fire = 0

func _physics_process(delta):
	if health <= 0:
		return
	
	check_player()
	
	if !isAggro:
		return
	
	#https://github.com/Miziziziz/Thine-Shooteth/blob/master/characters/BigBrain.gd
	#var l = player.global_transform.origin - global_transform.origin
	#l = l * 0.5
	var path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	if path.size() > 0 and health > 1:
		var dir = global_transform.origin.direction_to(path[1])
		dir.y = 0
		move_and_collide(dir.normalized() * speed * delta)
		$AnimatedSprite3D.play("walk")
	else:
		$AnimatedSprite3D.play("idle")
		
	var dir = player.global_transform.origin - global_transform.origin
	$RayCast.cast_to = dir.normalized() * weapon_range
		
	move_and_slide(Vector3.DOWN * 98 * delta);
	
	if last_time_since_fire + 2.75 > get_time():
		return
		
	if $RayCast.is_colliding():
		var c = $RayCast.get_collider()
		if c != null and c.name == "Player":
			c.health -= damage
			last_time_since_fire = get_time()
			$AnimatedSprite3D.play("fire")
			$AudioStreamPlayer3D.play()

func check_player():
	var distance = (global_transform.origin - player.global_transform.origin).length()
	var state = get_world().direct_space_state
	var result = state.intersect_ray(global_transform.origin, player.global_transform.origin)
	if !result or result.collider.name == "Player":
		isAggro = true
	
func get_time():
	return OS.get_ticks_msec() / 1000.0
	
func damage(damage):
	sprite_manager.play("hit")
	health -= damage
	check_health()

func check_health():
	if health <= 0:
		sprite_manager.play("dead")
		$RayCast.enabled = false
		#queue_free()
