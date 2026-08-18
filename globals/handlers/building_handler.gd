extends Node

signal production_tick(leafs_per_second: int)

const COST_SCALE := 1.15
const TICK_INTERVAL := 1.0

const BUILDINGS := {
	"seedling": {
		"name": "Brotinho",
		"description": "Um pequenino brotinho que cresce e produz folhas.",
		"base_price": 15,
		"production": 1
	},
	"tree": {
		"name": "Árvore",
		"description": "Uma árvore forte que produz muitas folhas.",
		"base_price": 100,
		"production": 5
	},
	"forest": {
		"name": "Floresta",
		"description": "Uma floresta inteira produzindo folhas.",
		"base_price": 1100,
		"production": 25
	},
	"solar_panel": {
		"name": "Painel Solar",
		"description": "Energia limpa que produz folhas automaticamente.",
		"base_price": 12000,
		"production": 100
	},
	"wind_turbine": {
		"name": "Eólica",
		"description": "Uma turbina eólica que gera folhas com o vento.",
		"base_price": 130000,
		"production": 500
	}
}

var _production_timer: Timer

func _ready() -> void:
	_production_timer = Timer.new()
	_production_timer.wait_time = TICK_INTERVAL
	_production_timer.timeout.connect(_on_production_tick)
	add_child(_production_timer)
	_production_timer.start()

func get_cost(building_id: String, owned: int) -> int:
	var data: Dictionary = BUILDINGS[building_id]
	return int(data["base_price"] * pow(COST_SCALE, owned))

func purchase(building_id: String, game: main_game) -> bool:
	var owned: int = game.buildings.get(building_id, 0)
	var cost := get_cost(building_id, owned)
	if game.leafs_count < cost:
		return false
	game.leafs_count -= cost
	game.buildings[building_id] = owned + 1
	game.leaf_changed.emit(game.leafs_count)
	return true

func get_production_per_second(game: main_game) -> int:
	var total := 0
	for building_id in game.buildings:
		var count: int = game.buildings[building_id]
		var data: Dictionary = BUILDINGS[building_id]
		total += data["production"] * count
	return total

func _on_production_tick() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var saveables := tree.get_nodes_in_group("saveables")
	for node in saveables:
		if node is main_game:
			var produced := get_production_per_second(node)
			if produced > 0:
				node.leafs_count += produced
				node.total_leafs += produced
				node.leaf_changed.emit(node.leafs_count)
			production_tick.emit(produced)
			break
