extends KinematicBody

var health = 1

func damage(damage):
	health -= damage
	check_health()

func check_health():
	if health <= 0:
		queue_free()
