extends Node

var amount_per_click: int = 1

func handle_click(game: main_game) -> void:
	var amount := calculate_click_value(game)

	apply_click(game, amount)

func calculate_click_value(game: main_game) -> int:
	return game.click * amount_per_click

func apply_click(game: main_game, amount: int) -> void:
	game.leafs_count += amount
	game.total_leafs += amount
	game.total_clicks += amount_per_click

	game.leaf_changed.emit(game.leafs_count)
