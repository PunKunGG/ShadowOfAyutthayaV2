extends Control

func _ready():
	$Complete.play()

func _on_Select_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://level_select.tscn")
	
func _on_Back_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
