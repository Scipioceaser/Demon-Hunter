extends KinematicBody

enum WEAPON {
	PISTOL,
	SHOTGUN,
	ROCKET_LAUNCHER
}

onready var PISTOL_SPRITE = preload("res://sprites/pistol_frames.tres")
onready var SHOTGUN_SPRITE = preload("res://sprites/shotgun_frames.tres")
onready var ROCKET_LAUNCHER_SPRITE = preload("res://sprites/rocket_launcher_frames.tres")
onready var weapon = $Camera/Gun

onready var PISTOL_UI_SPRITE = preload("res://sprites/pistol_ui.png")
onready var SHOTGUN_UI_SPRITE = preload("res://sprites/shotgun_ui.png")
onready var ROCKET_LAUNCHER_UI_SPRITE = preload("res://sprites/rocket_launcher_ui.png")

onready var pistol_sfx = preload("res://sfx/Pistol_Fire.wav")
onready var shotgun_sfx = preload("res://sfx/Shotgun_Fire.wav")
onready var rocket_launcher_sfx = preload("res://sfx/Rocket_Fire.wav")

onready var UI = $CanvasLayer/Menu

export var speed = 5.0;
export var rotate_speed = 45.0;
export var gravity = 500;
export var bunnyhop_multiplier = 10.0

export var current_weapon = WEAPON.PISTOL;

export var health = 8

export var pistol_ammo = 20
export var shotgun_ammo = 10
export var rockets = 2

var current_fire_rate = 1.0

export var weapon_has_index = 0

func _ready():
	name = "Player"
	create_weapon()
	UI.inGame = true
	UI.hide()
	pistol_ammo = PlayerStats.global_pistol_ammo
	shotgun_ammo = PlayerStats.global_shotgun_ammo
	rockets = PlayerStats.global_rockets
	weapon_has_index = PlayerStats.global_has_index

func create_weapon():
	if current_weapon == WEAPON.PISTOL:
		$CanvasLayer/Interface/Weapon.frames = PISTOL_SPRITE
		$CanvasLayer/Interface/Weapon.animation = "pistol"
		$CanvasLayer/Interface/Weapon.frame = 0
		current_fire_rate = WEAPON_STATS["pistol"].fire_rate
		weapon.damage = WEAPON_STATS["pistol"].damage
		weapon.fire_range = WEAPON_STATS["pistol"].range
		weapon.fire_count = 1
		$CanvasLayer/Interface/UI_Bar/AmmoCounter.text = str(pistol_ammo)
		$CanvasLayer/Interface/UI_Bar/WeaponIndicator.texture = PISTOL_UI_SPRITE
		$Camera/Gun/weapon_audio.stream = pistol_sfx
	elif current_weapon == WEAPON.SHOTGUN and weapon_has_index > 0:
		$CanvasLayer/Interface/Weapon.frames = SHOTGUN_SPRITE
		$CanvasLayer/Interface/Weapon.animation = "shotgun"
		$CanvasLayer/Interface/Weapon.frame = 0
		current_fire_rate = WEAPON_STATS["shotgun"].fire_rate
		weapon.damage = WEAPON_STATS["shotgun"].damage
		weapon.fire_range = WEAPON_STATS["shotgun"].range
		weapon.fire_count = 4
		$CanvasLayer/Interface/UI_Bar/AmmoCounter.text = str(shotgun_ammo)
		$CanvasLayer/Interface/UI_Bar/WeaponIndicator.texture = SHOTGUN_UI_SPRITE
		$Camera/Gun/weapon_audio.stream = shotgun_sfx		
	elif current_weapon == WEAPON.ROCKET_LAUNCHER  and weapon_has_index > 1:
		$CanvasLayer/Interface/Weapon.frames = ROCKET_LAUNCHER_SPRITE
		$CanvasLayer/Interface/Weapon.animation = "rocket_launcher"
		$CanvasLayer/Interface/Weapon.frame = 0
		current_fire_rate = WEAPON_STATS["rocket_launcher"].fire_rate
		weapon.damage = WEAPON_STATS["shotgun"].damage
		weapon.fire_range = WEAPON_STATS["shotgun"].range
		weapon.fire_count = 1
		$CanvasLayer/Interface/UI_Bar/AmmoCounter.text = str(rockets)
		$CanvasLayer/Interface/UI_Bar/WeaponIndicator.texture = ROCKET_LAUNCHER_UI_SPRITE
		$Camera/Gun/weapon_audio.stream = rocket_launcher_sfx		
	
var last_time_since_fire = 0.0
		
func player_fire():
	if last_time_since_fire + current_fire_rate > get_time() and last_time_since_fire != 0.0:
		return
	
	last_time_since_fire = get_time()
	
	var dir = global_transform.basis.z.normalized()
	var blowback = 0
	if current_weapon == WEAPON.PISTOL:
		if pistol_ammo > 0:
			blowback = WEAPON_STATS["pistol"].blowback_force
			weapon.fire()
			pistol_ammo -= 1
			$CanvasLayer/Interface/UI_Bar/AmmoCounter.text = str(pistol_ammo)
		else:
			return
	elif current_weapon == WEAPON.SHOTGUN:
		if shotgun_ammo > 0:
			blowback = WEAPON_STATS["shotgun"].blowback_force
			weapon.fire()
			#More work on subtraction
			shotgun_ammo -= 4
			shotgun_ammo = clamp(shotgun_ammo, 0, 10000)
			$CanvasLayer/Interface/UI_Bar/AmmoCounter.text = str(shotgun_ammo)
		else:
			return
	elif current_weapon == WEAPON.ROCKET_LAUNCHER:
		if rockets > 0:
			blowback = WEAPON_STATS["rocket_launcher"].blowback_force
			weapon.fire_rocket($Camera/rocket_spawn)
			rockets -= 1
			$CanvasLayer/Interface/UI_Bar/AmmoCounter.text = str(rockets)
		else:
			return
	
	$CanvasLayer/Interface/Weapon.frame = 1
	
	$Camera/Gun/weapon_audio.play()
	
	var move = dir * blowback
	
	if rotation_degrees.x == -45.0:
		move *= bunnyhop_multiplier
		
	move_and_slide(move)

func switch_weapon():
	if weapon_has_index == 0:
		return
	
	if weapon_has_index == 1 and current_weapon == 1:
		current_weapon = 0
	elif current_weapon == 2:
		current_weapon = 0
		print("b")
	elif current_weapon < 2:
		current_weapon += 1
		if weapon_has_index == 1:
			current_weapon = 1
	create_weapon()

func get_time():
	return OS.get_ticks_msec() / 1000.0

func _process(delta):
	if Input.is_action_just_released("ui_left"):
		rotation_degrees.y += rotate_speed;
	elif Input.is_action_just_released("ui_right"):
		rotation_degrees.y -= rotate_speed;
		
	if Input.is_action_just_pressed("ui_up") and rotation_degrees.x < rotate_speed:
		rotation_degrees.x += rotate_speed;
	if Input.is_action_just_pressed("ui_down") and rotation_degrees.x > -rotate_speed:
		rotation_degrees.x -= rotate_speed;
		
	if Input.is_action_just_released("ui_select"):
		player_fire()
		
	if Input.is_action_just_released("ui_cancel"):
		UI.show()
		$CanvasLayer/Interface.hide()
		get_tree().paused = true
		
	if Input.is_action_just_pressed("ui_accept"):
		switch_weapon()
		
	if Input.is_action_just_released("ui_reset"):
		get_tree().reload_current_scene()
		
	if last_time_since_fire + current_fire_rate < get_time() and last_time_since_fire != 0.0:
		$CanvasLayer/Interface/Weapon.frame = 0
		
	if pistol_ammo == 0 and shotgun_ammo == 0 and rockets == 0:
		pistol_ammo += 20
		
	$CanvasLayer/Interface/UI_Bar/HealthBar.frame = health - 1
	
	if health <= 0:
		get_tree().change_scene("res://prefabs/UI/Main Menu.tscn")
		
	#global_transform.origin = global_transform.origin.round()
	move_and_slide(Vector3.DOWN * gravity * delta);
	
		
const WEAPON_STATS = {
	"pistol" : {
		"damage" : 1,
		"fire_rate" : 0.5,
		"amount_bullets" : 1,
		"blowback_force" : 300,
		"range" : 75
	},
	"shotgun" : {
		"damage" : 1,
		"fire_rate" : 1.0,
		"amount_bullets" : 5,
		"blowback_force" : 600,
		"range" : 50
	},
	"rocket_launcher" : {
		"damage" : 3,
		"fire_rate" : 2.0,
		"amount_bullets" : 1,
		"blowback_force" : 850,
		"range" : 100
	}
}
