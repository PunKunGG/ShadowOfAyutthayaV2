extends Area2D

@export var required_item: String = "Rope"
@export var requirement_text: String = "Requirement: Rope"
@export var target_offset: Vector2 = Vector2(0, -100)
@export var do_warp := true  # ถ้า false จะไม่วาร์ป แต่ใช้ทำ action อื่นแทน เช่น จุดไฟ
@export var teleport_target: NodePath
@onready var label := $RequirementMessage

var player_ref: Node = null

func _ready():
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		label.visible = true
		label.text = "Press E to Interact"

func _on_body_exited(body):
	if body == player_ref:
		player_ref = null
		label.visible = false

func _process(_delta):
	if player_ref and Input.is_action_just_pressed("interact"):
		if Inventory.has_item(required_item):
			Inventory.use_item(required_item)
			if do_warp:
				if teleport_target != NodePath():
					var target_node = get_node_or_null(teleport_target)
					if target_node:
						player_ref.global_position = target_node.global_position
					else:
						print("❌ Teleport target not found.")
				else:
					player_ref.global_position += target_offset  # fallback ถ้าไม่ใช้ marker
			label.visible = false
		else:
			label.text = "❌ " + requirement_text

func _do_custom_action():
	# ตรงนี้จะถูกเรียกถ้า do_warp = false
	# คุณสามารถ override สคริปต์นี้ใน scene ที่สืบทอดเพื่อทำอย่างอื่น เช่น ก่อไฟ, ตัดไม้, สร้างสะพาน ฯลฯ
	print("🔥 Doing custom action with", required_item)
