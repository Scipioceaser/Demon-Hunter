extends Area

enum type {
	P,
	S,
	RL
}

export var current_type = type.P
export var amount = 5

func _on_ammo_kit_body_entered(body):
	if body.name == "Player":
		if current_type == type.P:
			body.pistol_ammo += amount
		elif current_type == type.S:
			body.shotgun_ammo += amount
		elif current_type == type.RL:
			body.rockets += amount 
			
		$AudioStreamPlayer.play()
			
		$Sprite3D.queue_free()
		$CollisionShape.queue_free()
			
		#queue_free()
