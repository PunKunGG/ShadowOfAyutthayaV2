extends Node2D

@onready var music := $AudioStreamPlayer

func _ready():
	if not music.playing:
		music.play()

func stop_music():
	music.stop()
