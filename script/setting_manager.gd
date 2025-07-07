extends Node

var config_path := "user://settings.cfg"
var config := ConfigFile.new()

func load_settings() -> Dictionary:
	var err = config.load(config_path)
	if err != OK:
		print("ยังไม่มี settings.cfg เริ่มจากค่า default")
	return {
		"music": config.get_value("audio", "music_volume", 1.0),
		"sfx": config.get_value("audio", "sfx_volume", 1.0),
		"fullscreen": config.get_value("display", "fullscreen", false),
	}

func save_settings(music: float, sfx: float, fullscreen: bool) -> void:
	config.set_value("audio", "music_volume", music)
	config.set_value("audio", "sfx_volume", sfx)
	config.set_value("display", "fullscreen", fullscreen)
	var err = config.save(config_path)
	if err != OK:
		print("เซฟไม่สำเร็จ: ", err)
	else:
		print("เซฟสำเร็จที่: ", config_path)
