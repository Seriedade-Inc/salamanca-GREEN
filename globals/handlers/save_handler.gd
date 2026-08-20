extends Node

const SAVE_PATH := "user://save.json"
const AUTO_SAVE_INTERVAL := 30.0

var _auto_save_timer: Timer

func _ready() -> void:
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	_auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)
	add_child(_auto_save_timer)
	_auto_save_timer.start()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			get_tree().call_group("saveables" , "save_game")
			get_tree().quit()	
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			get_tree().call_group("saveables", "save_game")

func get_default_data() -> Dictionary:
	return {
		"version": 1,
		"timestamp": 0,
		"leafs_count": 0,
		"click": 1,
		"total_leafs": 0,
		"total_clicks": 0,
		"buildings": { "seedling": 0 },
		"upgrades": {},
		"configurations": {
			"sound_volume": 1.0,
			"music_volume": 1.0
		}
	}

func save(data: Dictionary) -> void:
	data["timestamp"] = Time.get_unix_time_from_system()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveHandler: Could not open save file for writing. Error: " + str(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return get_default_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveHandler: Could not open save file for reading. Error: " + str(FileAccess.get_open_error()))
		return get_default_data()
	var json_string := file.get_as_text()
	file.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("SaveHandler: Could not parse save file. JSON Error: " + json.get_error_message())
		return get_default_data()
	var data = json.data
	if not data is Dictionary:
		push_error("SaveHandler: Save file is not a valid dictionary.")
		return get_default_data()
	return data

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func _on_auto_save_timer_timeout() -> void:
	get_tree().call_group("saveables", "save_game")
