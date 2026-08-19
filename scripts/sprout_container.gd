extends AspectRatioContainer

@onready var template: Label = $Indicators/Template
@onready var indicators: Control = $Indicators
@onready var sprout: TextureButton = $Sprout

func _on_sprout_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(sprout,"scale", Vector2(.9, .9), .1)


func _on_sprout_button_up() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(sprout,"scale", Vector2(1, 1), .1)


func _on_game_sprout_clicked(amount_per_click: int) -> void:
	var indicator = template.duplicate()
	indicator.text = "+" + str(amount_per_click)
	indicator.position = get_global_mouse_position()
	indicator.visible = true
	indicators.add_child(indicator)
	indicator.get_child(0).start()
