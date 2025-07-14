extends Node

var items := {
	"Rope": {"amount": 0, "consumable": false, "description": "ใช้สำหรับปีนต้นไม้หรือปีนที่สูง"},
	"Ladder": {"amount": 0, "consumable": false, "description": "บันไดไม้ ใช้สำหรับข้ามสิ่งกีดขวาง"},
	"Axe": {"amount": 0, "consumable": false, "description": "ขวาน ใช้ตัดต้นไม้หรือกำแพงบางจุด"},
	"Bottle": {"amount": 0, "consumable": true, "description": "ขวดเปล่า ใช้โยนล่อศัตรู"},
	"AshPowder": {"amount": 0, "consumable": true, "description": "ผงขี้เถ้า ใช้ดับคบเพลิงเพื่อสร้างทางมืด"}
}

func add_item(item_name: String, count := 1):
	if items.has(item_name):
		items[item_name]["amount"] += count
	else:
		push_error("❌ Item not recognized: " + item_name)

func has_item(item_name: String) -> bool:
	return items.has(item_name) and items[item_name]["amount"] > 0

func use_item(item_name: String) -> bool:
	if not has_item(item_name):
		return false

	if items[item_name]["consumable"]:
		items[item_name]["amount"] -= 1
	return true

func get_item_amount(item_name: String) -> int:
	if items.has(item_name):
		return items[item_name]["amount"]
	return 0
