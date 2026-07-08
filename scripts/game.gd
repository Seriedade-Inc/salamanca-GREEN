class_name main_game
extends Control

signal leaf_changed

var leafs_count = 0
var click = 1


func _on_texture_button_pressed() -> void:
	leafs_count += click
	emit_signal("leaf_changed", leafs_count)
