extends Control

@onready var btn_prologue = $VBoxContainer/Button_Prologue
@onready var btn_level1 = $VBoxContainer/Button_Level1
@onready var btn_level2 = $VBoxContainer/Button_Level2
@onready var btn_level3 = $VBoxContainer/Button_Level3
@onready var btn_level4 = $VBoxContainer/Button_Level4
@onready var btn_level5 = $VBoxContainer/Button_Level5

func _ready():
	update_buttons()

func update_buttons():
	btn_prologue.disabled = false
	btn_level1.disabled = not Global.unlocked_levels["Level1"]
	btn_level2.disabled = not Global.unlocked_levels["Level2"]
	btn_level3.disabled = not Global.unlocked_levels["Level3"]
	btn_level4.disabled = not Global.unlocked_levels["Level4"]
	btn_level5.disabled = not Global.unlocked_levels["Level5"]

func _on_Button_Prologue_pressed():
	MusicManager.stop_music()
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://prologue.tscn")

func _on_Button_Level1_pressed():
	MusicManager.stop_music()
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_Button_Level2_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	pass

func _on_Button_Level3_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	pass

func _on_Button_Level4_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	pass

func _on_Button_Level5_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	pass

func _on_Back_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
