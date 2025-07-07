extends Area2D

@export var target_scene_path := "res://cave_scene.tscn"
@export var hnomna_chance := 0.15
@export var hnomna_scene_path := "res://nhom_nha.tscn"  # 👈 ฉากจบลับ

@onready var interaction_label := $InteractionLabel

var player_in_range := false
var player_node : Node = null

func _ready():
	interaction_label.visible = false
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if randf() < hnomna_chance:
			# 👉 ไปฉากหนมน้าแบบจริงจังเลย
			get_tree().change_scene_to_file(hnomna_scene_path)
		else:
			get_tree().change_scene_to_file(target_scene_path)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_node = body
		interaction_label.visible = true
		interaction_label.text = "Press E to Enter"

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_node = null
		interaction_label.visible = false
