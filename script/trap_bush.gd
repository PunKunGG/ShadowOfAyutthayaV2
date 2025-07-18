extends Area2D

@export var is_trap := true

@onready var interaction_label := $InteractionLabel
@onready var enemy_area := $EnemyDetectionArea
@onready var scream := $scream

var hide_cooldown := 0.0
var takedown_cooldown := 0.0
const COOLDOWN_DURATION := 1.0

var player_in_range := false
var is_dead := false
var player_node : Node = null

func _ready():
	interaction_label.visible = false
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta):
	# ⏳ ลด cooldown
	hide_cooldown = max(hide_cooldown - _delta, 0)
	takedown_cooldown = max(takedown_cooldown - _delta, 0)
	
	if player_in_range and Input.is_action_just_pressed("interact") and hide_cooldown == 0 and not is_dead:
		player_node.toggle_hide()
		update_label()
		hide_cooldown = COOLDOWN_DURATION

		if is_trap and player_node.is_hidden:
			var damage := randi_range(7, 10)
			player_node.current_hp -= damage
			print("💥 พุ่มหลอกโจมตี! เสีย HP:", damage)

			if player_node.current_hp <= 0:
				if is_dead:
					return
					
				is_dead = true
				print("☠️ ตายจากสัตว์ในพุ่ม!")
				scream.play()
				interaction_label.text = "AHHHHHHHHHHHH!!!!"
				await scream.finished
				get_tree().change_scene_to_file("res://game_over_by_beast.tscn")

	if player_node and player_node.is_hidden and not is_dead and enemy_area.get_overlapping_bodies().any(func(b): return b.is_in_group("enemy")):
		interaction_label.text = "Press F to Takedown"
		interaction_label.visible = true  # ✅ เพิ่มไว้ให้แน่ใจ
		if Input.is_action_just_pressed("takedown") and takedown_cooldown == 0:
			print("🗡️ พยายามลอบสังหาร")
			player_node.cover_takedown(enemy_area.get_overlapping_bodies())
			takedown_cooldown = COOLDOWN_DURATION
	else:
		if not is_dead:
			update_label()  # ✅ ตรงนี้จะไม่ซ่อน label เพราะ update_label() ตรวจ is_hidden อยู่แล้ว


func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_node = body
		update_label()

func _on_body_exited(body):
	if body.name == "Player":
		if body.is_hidden:
			# ✅ ยังซ่อนอยู่ → อย่าลบ player_node เดี๋ยวพัง
			print("🚫 Player ออกจากพื้นที่ แต่ยังซ่อนอยู่ → ไม่ลบข้อมูล")
			return

		player_in_range = false
		player_node = null
		interaction_label.visible = false

func update_label():
	if is_dead:
		return
	
	if not player_node:
		interaction_label.visible = false
		return

	if player_node.is_hidden:
		interaction_label.text = "Press E to Exit Bush"
	else:
		interaction_label.text = "Press E to Hide"

	interaction_label.visible = true
