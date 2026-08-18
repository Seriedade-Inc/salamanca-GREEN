extends TextureButton
@onready var shine: TextureRect = $Shine

@export var despawn_time: float = 10.0 # Tempo que ela fica na tela antes de sumir
@export var Golden_Leaf_duration: float = 5.0

func _ready() -> void:
	pressed.connect(_on_pressed)
	await get_tree().create_timer(despawn_time).timeout
	expire_leaf()
		
func _on_pressed() -> void:
	pressed.disconnect(_on_pressed)
	disabled = true
	visible = false
	await activate_bonus()
	queue_free()

func activate_bonus() -> void:
	print("Folha Dourada Clicada! Multiplicador x2 por: ", Golden_Leaf_duration ," segundos!")
	ClickHandler.amount_per_click *= 2
	await get_tree().create_timer(Golden_Leaf_duration).timeout
	ClickHandler.amount_per_click /= 2 
	print("O efeito da Folha Dourada acabou.")

func expire_leaf() -> void:
	if is_inside_tree():
		print("A folha dourada sumiu porque o jogador demorou para clicar.")
		queue_free()
