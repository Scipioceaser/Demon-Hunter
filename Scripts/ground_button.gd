extends KinematicBody

onready var activate_area = $Area

export var node_to_destroy = ""

func _process(delta):
	var bodies = activate_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			$Base/AnimationPlayer.play("lower_button")
			get_node(node_to_destroy).queue_free()
