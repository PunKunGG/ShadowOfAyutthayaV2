extends Node2D

func _ready():
	TutorialManager.start_tutorial($Player/TutorialLabel)
	
	Global.last_played_scene = "res://prologue.tscn"
