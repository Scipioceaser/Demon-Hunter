extends Spatial

export var scene_to = ""

func _process(delta):
	var bodies = $Area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			PlayerStats.global_has_index = body.weapon_has_index
			PlayerStats.global_pistol_ammo = body.pistol_ammo
			PlayerStats.global_shotgun_ammo = body.shotgun_ammo
			PlayerStats.global_rockets = body.rockets
			get_tree().change_scene(scene_to)
