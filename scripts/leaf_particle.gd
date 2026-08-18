extends CPUParticles2D

var _textures: Array[Texture2D] = []

func _ready() -> void:
	_load_textures()
	texture = _textures.pick_random()

	amount = 1
	one_shot = true
	lifetime = 1.0
	explosiveness = 1.0

	direction = Vector2.UP
	spread = 40.0

	initial_velocity_min = 200.0
	initial_velocity_max = 400.0

	gravity = Vector2(0, 600)

	angular_velocity_min = -180.0
	angular_velocity_max = 180.0

	scale_amount_min = 0.15
	scale_amount_max = 0.25

	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	color_ramp = gradient

	emitting = true
	finished.connect(queue_free)

func _load_textures() -> void:
	if not _textures.is_empty():
		return
	for i in range(81, 102):
		var path := "res://assets/img/kenney_foliageSprites/PNG/Shaded/sprite_%04d.png" % i
		var tex := load(path) as Texture2D
		if tex:
			_textures.append(tex)

func setup_at(pos: Vector2) -> void:
	global_position = pos
