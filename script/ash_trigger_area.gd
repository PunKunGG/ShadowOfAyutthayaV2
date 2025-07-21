extends Area2D

@onready var prompt_label: Label = $PromptLabel

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("🧪 Player entered:", body.name)
		var torch_node = get_parent()
		print("🧪 Parent of AshTriggerArea is:", torch_node.name)
		print("🧪 Has try_extinguish:", torch_node.has_method("try_extinguish"))

		if torch_node and torch_node.has_method("try_extinguish"):
			body.torch_in_range = torch_node
			print("✅ torch_in_range set:", torch_node.name)
		else:
			print("❌ ไม่พบ try_extinguish หรือ parent ผิด")

func _on_body_exited(body):
	if body.is_in_group("player"):
		prompt_label.visible = false
		body.torch_in_range = null
