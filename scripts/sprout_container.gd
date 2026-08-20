extends AspectRatioContainer

@onready var template: Label = $Indicators/Template
@onready var indicators: Control = $Indicators
@onready var sprout: TextureButton = $Sprout

var _press_position := Vector2.ZERO

func _ready() -> void:
	template.visible = false
	sprout.gui_input.connect(_on_sprout_gui_input)

func _on_sprout_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_press_position = sprout.get_global_transform() * event.position
	elif event is InputEventScreenTouch and event.pressed:
		_press_position = sprout.get_global_transform() * event.position

func _on_sprout_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(sprout,"scale", Vector2(.9, .9), .1)


func _on_sprout_button_up() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(sprout,"scale", Vector2(1, 1), .1)


func _on_game_sprout_clicked(amount_per_click: int) -> void:
	var indicator = template.duplicate()
	indicator.text = "+" + str(amount_per_click)
	indicator.position = _press_position
	indicator.visible = true
	indicators.add_child(indicator)
	indicator.get_child(0).start()
