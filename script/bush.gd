extends Area2D

@onready var interaction_label := $InteractionLabel
@onready var enemy_area := $EnemyDetectionArea

var hide_cooldown := 0.0
var takedown_cooldown := 0.0
const COOLDOWN_DURATION := 1.0

var player_in_range := false
var player_node : Node = null

func _ready():
	interaction_label.visible = false
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta):
	# ⏳ ลด cooldown
	hide_cooldown = max(hide_cooldown - _delta, 0)
	takedown_cooldown = max(takedown_cooldown - _delta, 0)
	
	if player_in_range and Input.is_action_just_pressed("interact") and hide_cooldown == 0:
		player_node.toggle_hide()
		update_label()
		hide_cooldown = COOLDOWN_DURATION

	if player_node and player_node.is_hidden and enemy_area.get_overlapping_bodies().any(func(b): return b.is_in_group("enemy")):
		interaction_label.text = "Press F to Takedown"
		if Input.is_action_just_pressed("takedown") and takedown_cooldown == 0:
			player_node.cover_takedown(enemy_area.get_overlapping_bodies())
			takedown_cooldown = COOLDOWN_DURATION
	else:
		update_label()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_node = body
		update_label()

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_node = null
		interaction_label.visible = false

func update_label():
	if not player_node:
		interaction_label.visible = false
		return

	if player_node.is_hidden:
		interaction_label.text = "Press E to Exit Bush"
	else:
		interaction_label.text = "Press E to Hide"

	interaction_label.visible = true
