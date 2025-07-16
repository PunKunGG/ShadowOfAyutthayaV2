extends Area2D

@onready var label := $InteractionLabel
@onready var takedown_area := $TakedownDetection

var player_on_top := false
var player_node : Node = null
var can_jump_takedown := false
var target_enemy : Node = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	takedown_area.monitoring = true
	takedown_area.monitorable = true

	label.visible = false
	takedown_area.body_entered.connect(_on_takedown_area_entered)
	takedown_area.body_exited.connect(_on_takedown_area_exited)

func _process(_delta):
	if player_on_top and can_jump_takedown and Input.is_action_just_pressed("takedown"):
		print("🗡️ กระโดดลอบสังหารจากต้นไม้")
		if target_enemy and target_enemy.has_method("insta_kill"):
			target_enemy.insta_kill()
			var land_y_offset := -16
			player_node.global_position = target_enemy.global_position + Vector2(-32, land_y_offset)

			# ✅ ให้ player เล่น animation
			if player_node.has_method("play_tree_takedown"):
				player_node.play_tree_takedown()

			label.visible = false
			can_jump_takedown = false

func _on_body_entered(body):
	print("🧍 Player entered TreeTopArea:", body.name)
	if body.name == "Player":
		player_on_top = true
		player_node = body
		print("✅ player_on_top = true")

		# เช็กกรณี enemy อยู่ในพื้นที่แล้ว แต่ player เพิ่งขึ้นมา
		var bodies_in_takedown : Array= takedown_area.get_overlapping_bodies()
		for b in bodies_in_takedown:
			if b.is_in_group("enemy"):
				target_enemy = b
				can_jump_takedown = true
				label.text = "Press F to Jump Takedown"
				label.visible = true
				print("🧠 Enemy already in area:", b.name)
				break

func _on_body_exited(body):
	if body.name == "Player":
		player_on_top = false
		player_node = null
		label.visible = false
		can_jump_takedown = false

func _on_takedown_area_entered(body):
	print("👹 Enemy entered TakedownArea:", body.name)
	if body.is_in_group("enemy") and player_on_top:
		can_jump_takedown = true
		target_enemy = body
		label.text = "Press F to Jump Takedown"
		label.visible = true

func _on_takedown_area_exited(body):
	if body == target_enemy:
		can_jump_takedown = false
		target_enemy = null
		label.visible = false
