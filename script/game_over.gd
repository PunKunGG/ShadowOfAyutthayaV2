extends Control

func _ready():
	UiManager.hide_ui()
	$Dead.play()

func _on_again_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(Global.last_played_scene)

func _on_back_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	ScreenLoader.load_scene("res://main_menu.tscn")
