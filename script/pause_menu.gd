extends CanvasLayer

@onready var panel = $Panel

func  _ready():
	$Label.visible = false
	panel.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()

func _pause_game():
	get_tree().paused = true
	$Label.visible = true
	panel.visible = true

func _resume_game():
	get_tree().paused = false
	$Label.visible = false
	panel.visible = false

func _on_resume_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	_resume_game()

func _on_main_menu_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_setting_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	pass
