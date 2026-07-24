extends Node

var min_time: float = 16.0
var max_time: float = 20.0
var target_layer: Node = null
var golden_leaf_scene: PackedScene = preload("res://scenes/GoldenLeaf.tscn")
var Event_Timer: Timer 

func _ready() -> void:
	print("Event timer started")
	Event_Timer = Timer.new()
	add_child(Event_Timer)
	Event_Timer.one_shot = true
	Event_Timer.timeout.connect(_on_Event_timer_timeout)
	start_next_event_countdown()	
	
func start_next_event_countdown() -> void:
	var random_wait_time = randf_range(min_time, max_time)
	Event_Timer.wait_time = random_wait_time
	Event_Timer.start()
	print('Next Event in: ', random_wait_time, ' seconds!')

func _on_Event_timer_timeout() -> void:
	spawn_golden_leaf()
	start_next_event_countdown()

func spawn_golden_leaf() -> void:
	if not golden_leaf_scene:
		push_error("A cena da folha dourada não foi carregada corretamente!")
		return
	
	if not target_layer:
		target_layer = get_tree().current_scene.find_child("ScreenEventLayer", true, false)
	
	if not target_layer:
		print("ScreenEventLayer não encontrado na cena atual. Cancelando spawn.")
		return
	
	var leaf_instance = golden_leaf_scene.instantiate()
	
	
	target_layer.add_child(leaf_instance)
	
	
	leaf_instance.z_index = 5 
	
	
	var screen_size = get_viewport().get_visible_rect().size
	var random_x = randf_range(100, screen_size.x - 100)
	var random_y = randf_range(100, screen_size.y - 100)
	
	leaf_instance.global_position = Vector2(random_x, random_y)
	print("Folha Dourada surgiu na tela em: ", leaf_instance.global_position)
