extends Control

@onready var label := $Label
@onready var audio := $Piichaa

func _ready():
	label.text = "ไม่ไหวแล้ว 🥵 😈 โดนพี่จ๋า!"
	audio.play()

func  _on_replay_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_back_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
