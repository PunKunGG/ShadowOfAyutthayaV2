extends Control

@onready var music_slider = $MusicVolumn/HSlider
@onready var sfx_slider = $SFXVolumn/HSlider
@onready var fullscreen_check = $Fullscreen/CheckBox

func _ready():
	var music_player = get_node("/root/MusicManager/AudioStreamPlayer")
	if music_player:
		music_slider.value = db_to_linear(music_player.volume_db)

	var sfx_index = AudioServer.get_bus_index("SFX")
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))

	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	music_slider.value_changed.connect(_on_music_slider_changed)
	music_slider.value_changed.connect(_on_any_setting_changed)  # เพิ่ม

	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	sfx_slider.value_changed.connect(_on_any_setting_changed)    # เพิ่ม

	fullscreen_check.toggled.connect(_on_fullscreen_toggle)
	fullscreen_check.toggled.connect(_on_any_setting_changed)    # เพิ่ม


func _on_music_slider_changed(value: float) -> void:
	var music_player = get_node("/root/MusicManager/AudioStreamPlayer")
	if music_player:
		music_player.volume_db = linear_to_db(value)

func _on_sfx_slider_changed(value: float) -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))

func _on_fullscreen_toggle(pressed: bool) -> void:
	DisplayServer.window_set_mode(
	DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_any_setting_changed():
	SettingManager.save_settings(
	music_slider.value,
	sfx_slider.value,
	fullscreen_check.button_pressed)

func _on_back_button_pressed():
	$Click.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
