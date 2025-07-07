extends Node

var score := 0
var upgrade_level := 1  # เริ่มที่ Lv.1

func get_qte_range() -> Vector2i:
	match upgrade_level:
		1:
			return Vector2i(3, 5)
		2:
			return Vector2i(2, 4)
		3:
			return Vector2i(1, 3)
	return Vector2i(5, 5)  # fallback

func can_upgrade() -> bool:
	return upgrade_level < 3 and score >= get_upgrade_cost()

func get_upgrade_cost() -> int:
	return 50 * upgrade_level  # เช่น Lv.1→2 ใช้ 10, Lv.2→3 ใช้ 20

func upgrade():
	if can_upgrade():
		score -= get_upgrade_cost()
		upgrade_level += 1
