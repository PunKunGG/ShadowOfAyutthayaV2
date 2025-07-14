extends Node

var current_step := 0
var steps := []
var label_node: Label = null

func start_tutorial(label: Label):
	current_step = 0
	label_node = label

	steps = [
		"กด A / D เพื่อเดินซ้ายขวา",
		"กด W เพื่อกระโดด",
		"กด E เพื่อซ่อนตัวในพุ่มไม้",
		"ระวังพุ่มไม้กินคน",
		"กด E เพื่อตรวจสอบ / เก็บไอเท็ม",
		"กด I เพื่อเปิด Inventory",
		"เมื่ออยู่ด้านหลังศัตรู ให้กด F เพื่อลอบสังหาร",
		"ในการลอบสังหาร จงเลือกคำที่ถูกต้อง",
		"กด Q เพื่อใช้ท่าต่อสู้",
		"กด E เพื่อใช้เชือกในการปีนต้นไม้"
	]

	show_current_step()

func show_current_step():
	if label_node and current_step < steps.size():
		label_node.text = steps[current_step]
		label_node.visible = true
	else:
		end_tutorial()

func show_message(message: String, duration: float = 2.0):
	if not label_node:
		print("❌ label_node ยังไม่ถูกเซ็ต")
		return

	label_node.text = message
	label_node.visible = true

	await get_tree().create_timer(duration).timeout
	label_node.visible = false

func next_step():
	current_step += 1
	if current_step >= steps.size():
		end_tutorial()
	else:
		show_current_step()

func end_tutorial():
	if label_node:
		label_node.visible = false
