extends Node

var items: Dictionary = {}

func add_item(item_name: String, amount := 1):
	if items.has(item_name):
		items[item_name] += amount
	else:
		items[item_name] = amount
	
	print("🎒 ได้: ", item_name, " จำนวน ", items[item_name])

func has_item(item_name: String) -> bool:
	return items.has(item_name) and items[item_name] > 0

func remove_item(item_name: String, amount := 1):
	if has_item(item_name):
		items[item_name] -= amount
		if items[item_name] <= 0:
			items.erase(item_name)
