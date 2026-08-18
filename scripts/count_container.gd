extends VBoxContainer
@onready var leaf_count_label: Label = $LeafCount

func _on_game_leaf_changed(leaf_count) -> void:
	leaf_count_label.text = str(leaf_count) + " Folhas"
