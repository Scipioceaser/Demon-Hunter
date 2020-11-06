extends Area

export var amount = 1

func _on_health_kit_body_entered(body):
	if body.name == "Player":
		body.health += 1
		
		$AudioStreamPlayer.play()
		
		$CollisionShape.queue_free()
		$Sprite3D.queue_free()
