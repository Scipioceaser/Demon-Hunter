extends Timer

func _on_Timer_timeout():
	get_tree().get_nodes_in_group("player")[0].health = 0
