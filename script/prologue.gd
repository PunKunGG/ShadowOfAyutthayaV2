extends Node2D

func _ready():
	TutorialManager.start_tutorial($Player/TutorialLabel)
	
