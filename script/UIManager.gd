extends Node

var ui_instance: Node = null
var ui_scene := preload("res://ui.tscn")

func show_ui():
	if not ui_instance:
		ui_instance = ui_scene.instantiate()
		get_tree().root.call_deferred("add_child", ui_instance)
		await ui_instance.ready  # 🔁 รอให้ Node พร้อม

func hide_ui():
	if ui_instance:
		ui_instance.queue_free()
		ui_instance = null

func set_objectives(objective1: String, objective2: String):
	if not ui_instance: return
	ui_instance.set_objectives(objective1, objective2)

func mark_rope_collected():
	if not ui_instance: return
	ui_instance.mark_rope_collected()

func mark_ladder_collected():
	if not ui_instance: return
	ui_instance.mark_ladder_collected()

func update_health_bar(current: int, _max: int):
	if not ui_instance: return
	ui_instance.update_health_bar(current, _max)

func update_stamina_bar(current: int, _max: int):
	if not ui_instance: return
	ui_instance.update_stamina_bar(current, _max)
