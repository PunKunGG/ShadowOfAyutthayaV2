extends Node2D

func _ready():
	TutorialManager.start_tutorial($Player/TutorialLabel)
	
	Global.unlocked_levels["Level1"] = true
