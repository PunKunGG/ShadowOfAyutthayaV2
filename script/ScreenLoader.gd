extends Node

var loading_screen := preload("res://loading_screen.tscn")
var current_loading: CanvasLayer = null
var progress_bar: ProgressBar = null

func load_scene(path: String) -> void:
	current_loading = loading_screen.instantiate()
	get_tree().root.add_child(current_loading)
	await get_tree().process_frame

	progress_bar = current_loading.get_node("LoadingAnim")
	progress_bar.value = 0

	# จำลอง progress bar
	for i in 100:
		progress_bar.value = float(i) / 20.0 * 100.0
		await get_tree().create_timer(0.05).timeout

	# โหลดฉาก (block เป็นช่วงสั้นๆ)
	var new_scene := ResourceLoader.load(path)
	if new_scene is PackedScene:
		get_tree().change_scene_to_packed(new_scene)

	current_loading.queue_free()
	current_loading = null
