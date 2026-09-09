extends Node

signal upgrade_purchased(upgrade_id: String)
signal upgrades_changed

const UPGRADES := {
	"click_power_1": {
		"name": "Poder de Clique I",
		"description": "Aumenta o valor de cada clique em +1.",
		"base_price": 50,
		"category": "click",
		"effect": { "type": "click_add", "value": 1 },
		"prerequisite": null
	},
	"click_power_2": {
		"name": "Poder de Clique II",
		"description": "Aumenta o valor de cada clique em +2.",
		"base_price": 500,
		"category": "click",
		"effect": { "type": "click_add", "value": 2 },
		"prerequisite": "click_power_1"
	},
	"click_power_3": {
		"name": "Poder de Clique III",
		"description": "Aumenta o valor de cada clique em +5.",
		"base_price": 5000,
		"category": "click",
		"effect": { "type": "click_add", "value": 5 },
		"prerequisite": "click_power_2"
	},
	"click_multiplier": {
		"name": "Multiplicador de Clique",
		"description": "Dobra o valor de todos os cliques.",
		"base_price": 10000,
		"category": "click",
		"effect": { "type": "click_multiplier", "value": 2.0 },
		"prerequisite": "click_power_2"
	},
	"seedling_boost": {
		"name": "Sementes Especiais",
		"description": "Dobra a produção de Brotilhos.",
		"base_price": 200,
		"category": "production",
		"effect": { "type": "building_production", "building": "seedling", "multiplier": 2.0 },
		"prerequisite": null
	},
	"tree_boost": {
		"name": "Árvores Genéticas",
		"description": "Dobra a produção de Árvores.",
		"base_price": 1500,
		"category": "production",
		"effect": { "type": "building_production", "building": "tree", "multiplier": 2.0 },
		"prerequisite": "seedling_boost"
	},
	"forest_boost": {
		"name": "Florestas Sustentáveis",
		"description": "Dobra a produção de Florestas.",
		"base_price": 15000,
		"category": "production",
		"effect": { "type": "building_production", "building": "forest", "multiplier": 2.0 },
		"prerequisite": "tree_boost"
	},
	"solar_boost": {
		"name": "Painéis Avançados",
		"description": "Dobra a produção de Painéis Solares.",
		"base_price": 150000,
		"category": "production",
		"effect": { "type": "building_production", "building": "solar_panel", "multiplier": 2.0 },
		"prerequisite": "forest_boost"
	},
	"wind_boost": {
		"name": "Turbinas Premium",
		"description": "Dobra a produção de Eólicas.",
		"base_price": 1500000,
		"category": "production",
		"effect": { "type": "building_production", "building": "wind_turbine", "multiplier": 2.0 },
		"prerequisite": "solar_boost"
	},
	"global_production_boost": {
		"name": "Eficiência Global",
		"description": "Aumenta toda a produção em 50%.",
		"base_price": 50000,
		"category": "production",
		"effect": { "type": "global_production_multiplier", "value": 1.5 },
		"prerequisite": "forest_boost"
	},
	"discount_10": {
		"name": "Desconto 10%",
		"description": "Reduz o custo de todos os prédios em 10%.",
		"base_price": 5000,
		"category": "economy",
		"effect": { "type": "building_discount", "value": 0.1 },
		"prerequisite": "tree_boost"
	},
	"discount_25": {
		"name": "Desconto 25%",
		"description": "Reduz o custo de todos os prédios em 25%.",
		"base_price": 25000,
		"category": "economy",
		"effect": { "type": "building_discount", "value": 0.25 },
		"prerequisite": "discount_10"
	},
	"golden_boost": {
		"name": "Folha Dourada Fortalecida",
		"description": "A duração da Folha Dourada é o dobro.",
		"base_price": 3000,
		"category": "special",
		"effect": { "type": "golden_leaf_duration", "multiplier": 2.0 },
		"prerequisite": null
	}
}

var _click_additive_bonus: int = 0
var _click_multiplier: float = 1.0
var _building_production_multipliers: Dictionary = {}
var _global_production_multiplier: float = 1.0
var _building_discount: float = 0.0
var _golden_leaf_duration_multiplier: float = 1.0

func get_cost(upgrade_id: String) -> int:
	var data: Dictionary = UPGRADES[upgrade_id]
	return data["base_price"]

func is_purchased(upgrade_id: String, game: main_game) -> bool:
	return game.upgrades.has(upgrade_id) and game.upgrades[upgrade_id]

func can_purchase(upgrade_id: String, game: main_game) -> bool:
	if is_purchased(upgrade_id, game):
		return false
	var data: Dictionary = UPGRADES[upgrade_id]
	var prerequisite: String = data.get("prerequisite", "")
	if prerequisite != "" and not is_purchased(prerequisite, game):
		return false
	return game.leafs_count >= get_cost(upgrade_id)

func purchase(upgrade_id: String, game: main_game) -> bool:
	if not can_purchase(upgrade_id, game):
		return false
	var cost := get_cost(upgrade_id)
	game.leafs_count -= cost
	game.upgrades[upgrade_id] = true
	game.leaf_changed.emit(game.leafs_count)
	_recalculate_effects(game)
	upgrade_purchased.emit(upgrade_id)
	upgrades_changed.emit()
	return true

func _recalculate_effects(game: main_game) -> void:
	_click_additive_bonus = 0
	_click_multiplier = 1.0
	_building_production_multipliers = {}
	_global_production_multiplier = 1.0
	_building_discount = 0.0
	_golden_leaf_duration_multiplier = 1.0

	for upgrade_id in game.upgrades:
		if not game.upgrades[upgrade_id]:
			continue
		if not UPGRADES.has(upgrade_id):
			continue
		var data: Dictionary = UPGRADES[upgrade_id]
		var effect: Dictionary = data["effect"]
		match effect["type"]:
			"click_add":
				_click_additive_bonus += effect["value"]
			"click_multiplier":
				_click_multiplier *= effect["value"]
			"building_production":
				var building: String = effect["building"]
				var mult: float = effect["multiplier"]
				_building_production_multipliers[building] = _building_production_multipliers.get(building, 1.0) * mult
			"global_production_multiplier":
				_global_production_multiplier *= effect["value"]
			"building_discount":
				_building_discount = maxf(_building_discount, effect["value"])
			"golden_leaf_duration":
				_golden_leaf_duration_multiplier *= effect["multiplier"]

func get_click_value(game: main_game) -> int:
	return int((game.click + _click_additive_bonus) * _click_multiplier)

func get_building_production(building_id: String, base_production: int) -> int:
	var mult: float = _building_production_multipliers.get(building_id, 1.0)
	return int(base_production * mult * _global_production_multiplier)

func get_building_cost(base_cost: int) -> int:
	return int(base_cost * (1.0 - _building_discount))

func get_golden_leaf_duration(base_duration: float) -> float:
	return base_duration * _golden_leaf_duration_multiplier

func init_upgrades(game: main_game) -> void:
	for upgrade_id in UPGRADES:
		if not game.upgrades.has(upgrade_id):
			game.upgrades[upgrade_id] = false

func get_available_upgrades(game: main_game) -> Array:
	var available := []
	for upgrade_id in UPGRADES:
		if can_purchase(upgrade_id, game):
			available.append(upgrade_id)
	return available

func get_purchased_upgrades(game: main_game) -> Array:
	var purchased := []
	for upgrade_id in game.upgrades:
		if game.upgrades[upgrade_id]:
			purchased.append(upgrade_id)
	return purchased
