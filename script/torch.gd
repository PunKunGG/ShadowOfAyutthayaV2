extends Node2D

@onready var torch_area := $TorchArea
@onready var prompt := $AshTriggerArea/PromptLabel
@onready var sprite := $AnimatedSprite2D

var is_lit := true
var player_inside := false

func _ready():
	prompt.visible = false
	$AshTriggerArea.connect("body_entered", _on_body_entered)
	$AshTriggerArea.connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player") and is_lit:
		prompt.text = "กด R เพื่อโยนขี้เถ้าดับไฟ"  # ✅ แก้ตรงนี้
		prompt.visible = true
		player_inside = true
		print("ผู้เล่นเข้ามาในเขตดับไฟ")

func _on_body_exited(body):
	if body.is_in_group("player"):
		prompt.visible = false
		player_inside = false
		print("ผู้เล่นเข้าออกจากเขตดับไฟ")

func try_extinguish():
	if not is_lit:
		return
	is_lit = false
	prompt.visible = false
	sprite.visible = false  # หรือ sprite.play("extinguish")
	torch_area.extinguish()

func show_prompt(text: String):
	var label := get_node_or_null("AshTriggerArea/PromptLabel")
	if label and label is Label:
		label.text = text
		label.visible = true
		await get_tree().create_timer(2.0).timeout
		label.visible = false
	else:
		print("❌ ไม่พบหรือไม่ใช่ Label: AshTriggerArea/PromptLabel")
