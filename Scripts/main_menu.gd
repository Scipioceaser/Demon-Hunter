extends Control

var index = 0

var mode = 0

var optionsIndex = 0

var inGame = false

var volume = 100

func _ready():
	$OptionsMenu.hide()
	$MainMenu.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if !visible:
		return
	
	if mode == 0:
		if Input.is_action_just_released("ui_accept"):
			$AudioStreamPlayer.play()
			index += 1
			if index == 3:
				index = 0

		if index == 0:
			$MainMenu/SelectButton.rect_global_position.y = 49
		elif index == 1:
			$MainMenu/SelectButton.rect_global_position.y = 49 + 17
		elif index == 2:
			$MainMenu/SelectButton.rect_global_position.y = 49 + (17 * 2)
	
		if Input.is_action_just_released("ui_select"):
			$AudioStreamPlayer.play()
			if index == 0:
				if !inGame:
					get_tree().change_scene("res://Maps/Introduction.tscn")
					index = 0
				else:
					get_tree().paused = false
					get_parent().get_node("Interface").show()
					hide()
					index = 0
			elif index == 1:
				mode = 1
				optionsIndex = 0
				index = 0
				$MainMenu.hide()
				$OptionsMenu.show()
			elif index == 2:
				get_tree().quit()
	elif mode == 1:
		if Input.is_action_just_released("ui_accept"):
			$AudioStreamPlayer.play()
			optionsIndex += 1
			if optionsIndex == 3:
				optionsIndex = 0
		
		if optionsIndex == 0:
			$OptionsMenu/SelectButton2.rect_global_position.y = 48
		elif optionsIndex == 1:
			$OptionsMenu/SelectButton2.rect_global_position.y = 48 + 17
		elif optionsIndex == 2:
			$OptionsMenu/SelectButton2.rect_global_position.y = 48 + (2 * 17)
			
		if Input.is_action_just_released("ui_select"):
			$AudioStreamPlayer.play()
			if optionsIndex == 0:
				if OS.window_fullscreen:
					OS.window_fullscreen = false
					$OptionsMenu/AnimatedSprite.frame = 0
				else:
					OS.window_fullscreen = true
					$OptionsMenu/AnimatedSprite.frame = 1
			elif optionsIndex == 2:
				mode = 0
				optionsIndex = 0
				index = 0
				$OptionsMenu.hide()
				$MainMenu.show()
		
		if Input.is_action_just_released("ui_up") and optionsIndex == 1:
			$AudioStreamPlayer.play()
			volume += 25
		elif Input.is_action_just_released("ui_down") and optionsIndex == 1:
			$AudioStreamPlayer.play()
			volume -= 25

		volume = clamp(volume, 0, 100)
		AudioServer.set_bus_volume_db(0, linear2db(volume / 100.0))
		$OptionsMenu/VBoxContainer/HBoxContainer2/Label3.text = str(round(db2linear(AudioServer.get_bus_volume_db(0)) * 100.0))
