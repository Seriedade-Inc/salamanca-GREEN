extends Node

func handle_click(game: main_game) -> void:
	var amount := calculate_click_value(game)

	apply_click(game, amount)

func calculate_click_value(game: main_game) -> int:
	return game.click

func apply_click(game: main_game, amount: int) -> void:
	game.leafs_count += amount
	game.total_leafs += amount
	game.total_clicks += 1

	game.leaf_changed.emit(game.leafs_count)
