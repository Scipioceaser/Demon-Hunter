extends Area

export(int, 1, 2) var type = 1

func _on_weapon_pickup_body_entered(body):
	if body.name == "Player":
		body.weapon_has_index = type
		$AudioStreamPlayer.play()
	
		$Sprite3D.queue_free()
		$CollisionShape.queue_free()
