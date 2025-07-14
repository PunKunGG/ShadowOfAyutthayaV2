extends Control

func _ready():
	if MusicManager:  # ถ้าใช้ autoload แล้ว
		var music = MusicManager.get_node("AudioStreamPlayer")
		if music and not music.playing:
			music.play()

func _on_start_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_setting_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://setting.tscn")

func _on_exit_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()

func _on_credit_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://credit.tscn")

func _on_test_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://upgrade_character.tscn")

func _on_htp_pressed() -> void:
	MusicManager.stop_music()
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://how_to_play.tscn")
