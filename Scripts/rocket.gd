extends RigidBody

var speed = 10.0
var damage = 2

const totalLife = 20.0
var lifetime = 0.0

onready var kill_area = $kill_area

onready var explosion_prefab = preload("res://prefabs/explosion.tscn")

func _ready():
	connect("body_entered", self, "collide")
	
func collide(body):
	var e = explosion_prefab.instance()
	e.global_transform = global_transform
	get_tree().get_root().add_child(e)
	
	sleeping = true
	
	var bodies = kill_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("damage"):
			body.damage(damage)
	
	queue_free()
