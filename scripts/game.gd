class_name main_game
extends Control

signal leaf_changed

var leafs_count := 0
var click := 1
var total_leafs := 0
var total_clicks := 0
var upgrades := {}
var configurations := {}

func _ready() -> void:
	add_to_group("saveables")
	_load_game()

func _on_texture_button_pressed() -> void:
	ClickHandler.handle_click(self)
	
func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"leafs_count": leafs_count,
		"click": click,
		"total_leafs": total_leafs,
		"total_clicks": total_clicks,
		"upgrades": upgrades,
		"configurations": configurations
	}

func _load_game() -> void:
	var data := SaveHandler.load_data()
	leafs_count = data.get("leafs_count", 0)
	click = data.get("click", 1)
	total_leafs = data.get("total_leafs", 0)
	total_clicks = data.get("total_clicks", 0)
	upgrades = data.get("upgrades", {})
	configurations = data.get("configurations", {})
	emit_signal("leaf_changed", leafs_count)

func save_game() -> void:
	SaveHandler.save(get_save_data())
