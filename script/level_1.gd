extends Node2D

func _ready():
	Global.last_played_scene = "res://level_1.tscn"
	UiManager.show_ui()
	await get_tree().process_frame 
	
	UiManager.set_objectives("เก็บเชือก", "เก็บบันได")
