extends CanvasLayer

@onready var panel := $Panel
@onready var item_list := $Panel/MarginContainer/HBoxContainer
@onready var text := $Inventory
@onready var background := $BG
@onready var slot_scene := preload("res://ui/slot.tscn")  # เปลี่ยน path ให้ถูก

func _ready():
	text.visible = false
	panel.visible = false
	background.visible = false

func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		panel.visible = !panel.visible
		text.visible = !text.visible
		background.visible = !background.visible
		
		get_tree().paused = panel.visible
		
		if panel.visible:
			update_inventory_display()

func update_inventory_display():
	# ลบลูกทั้งหมดใน VBoxContainer
	for child in item_list.get_children():
		child.queue_free()

	for item_name in Inventory.items.keys():
		var amount = Inventory.items[item_name]
		
		var slot = slot_scene.instantiate()
		var texture_rect = slot.get_node("TextureRect")
		var label = slot.get_node("Label")
		
		texture_rect.texture = get_icon_for_item(item_name)
		label.text = "%s x%d" % [item_name, amount]

		item_list.add_child(slot)

func get_icon_for_item(_name: String) -> Texture2D:
	# 👇 ใส่ logic ให้โหลด icon ตามชื่อ หรือใช้ preload dictionary
	match _name:
		"ขวาน":
			return preload("res://assets/tools/axe_real.PNG")
		"เชือก":
			return preload("res://assets/tools/rope_real.PNG")
		"กิ่งไม้":
			return preload("res://assets/tools/stick-removebg-preview.png")
		_:
			return null
