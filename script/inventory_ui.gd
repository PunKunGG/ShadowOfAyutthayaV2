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
		var item_data = Inventory.items[item_name]
		var amount = item_data["amount"]
		
		if amount > 0:
			add_item_slot(item_name)

func add_item_slot(item_name: String):
	var data = Inventory.items[item_name]
	var amount = data["amount"]
	var description = data["description"]

	var slot = slot_scene.instantiate()
	var texture_rect = slot.get_node("TextureRect")
	var label = slot.get_node("Label")
	var tooltip_label = slot.get_node("TooltipLabel")

	texture_rect.texture = get_icon_for_item(item_name)
	label.text = "%s x%d" % [item_name, amount]
	tooltip_label.text = description
	tooltip_label.visible = false  # เริ่มซ่อนไว้

	# Mouse enter/exit
	slot.mouse_entered.connect(func():
		tooltip_label.visible = true
	)
	slot.mouse_exited.connect(func():
		tooltip_label.visible = false
	)

	item_list.add_child(slot)


func get_icon_for_item(_name: String) -> Texture2D:
	# 👇 ใส่ logic ให้โหลด icon ตามชื่อ หรือใช้ preload dictionary
	match _name:
		"Axe":
			return preload("res://assets/tools/axe_real.PNG")
		"Rope":
			return preload("res://assets/tools/rope_real.PNG")
		"Stick":
			return preload("res://assets/tools/stick-removebg-preview.png")
		_:
			return null
