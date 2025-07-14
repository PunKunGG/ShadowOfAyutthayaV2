extends Area2D

@export var countdown_time := 3.0
@export var next_scene: String = "res://nhom_nha.tscn"

@onready var label := $Label
@onready var audio := $RizzWalk

var player_in_zone := false
var timer := 0.0
var counting := false

func _ready():
	label.visible = false

func _process(delta):
	if player_in_zone and counting:
		timer -= delta
		label.text = "กำลังออกจากพื้นที่... %.1f" % timer

		if timer <= 0:
			audio.stop()
			get_tree().change_scene_to_file(next_scene)
	else:
		timer = countdown_time
		label.visible = false
		audio.stop()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		counting = true
		label.visible = true
		label.text = "กำลังออกจากพื้นที่... %.1f" % countdown_time
		audio.play()
		print("🟢 ผู้เล่นเข้ามาในเขตอพยพ")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		counting = false
		label.visible = false
		audio.stop()
		print("🔴 ผู้เล่นออกจากเขตอพยพ")
