class_name main_game
extends Control

signal leaf_changed
signal buildings_changed
signal Sprout_Clicked

var leafs_count := 0
var click := 1
var total_leafs := 0
var total_clicks := 0
var buildings := {}
var upgrades := {}
var configurations := {}

const LEAF_PARTICLE := preload("res://scenes/leaf_particle.tscn")

func _ready() -> void:
	EventHandler.target_layer = $ScreenEventLayer
	add_to_group("saveables")
	_init_buildings()
	_load_game()

func _init_buildings() -> void:
	for building_id in BuildingHandler.BUILDINGS:
		buildings[building_id] = 0

func _on_texture_button_pressed() -> void:
	ClickHandler.handle_click(self)
	emit_signal("Sprout_Clicked", ClickHandler.amount_per_click)
	_spawn_leaf_particle()

func _spawn_leaf_particle() -> void:
	var particle: CPUParticles2D = LEAF_PARTICLE.instantiate()
	particle.setup_at(get_global_mouse_position())
	$ScreenEventLayer.add_child(particle)

func purchase_building(building_id: String) -> bool:
	var success := BuildingHandler.purchase(building_id, self)
	if success:
		buildings_changed.emit()
	return success

func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"leafs_count": leafs_count,
		"click": click,
		"total_leafs": total_leafs,
		"total_clicks": total_clicks,
		"buildings": buildings,
		"upgrades": upgrades,
		"configurations": configurations
	}

func _load_game() -> void:
	var data := SaveHandler.load_data()
	leafs_count = data.get("leafs_count", 0)
	click = data.get("click", 1)
	total_leafs = data.get("total_leafs", 0)
	total_clicks = data.get("total_clicks", 0)
	var saved_buildings: Dictionary = data.get("buildings", {})
	for building_id in BuildingHandler.BUILDINGS:
		buildings[building_id] = saved_buildings.get(building_id, 0)
	upgrades = data.get("upgrades", {})
	configurations = data.get("configurations", {})
	leaf_changed.emit(leafs_count)
	buildings_changed.emit()

func save_game() -> void:
	SaveHandler.save(get_save_data())
