extends AudioStreamPlayer

var lista_sfx: Array[AudioStream] = []
var ultimo_indice: int = -1
var pode_tocar: bool = true

func _ready() -> void:
	carregar_efeitos()

func carregar_efeitos() -> void:
	var pasta = "res://assets/sfx/"
	var dir = DirAccess.open(pasta)
	
	if dir:
		dir.list_dir_begin()
		var nome_arquivo = dir.get_next()
		
		while nome_arquivo != "":
			if not dir.current_is_dir():
				# Corrige o nome para evitar bugs se o jogo for exportado
				var nome_limpo = nome_arquivo.replace(".remap", "").replace(".import", "")
				
				if nome_limpo.ends_with(".wav") or nome_limpo.ends_with(".mp3") or nome_limpo.ends_with(".ogg"):
					var caminho_completo = pasta.path_join(nome_limpo)
					var audio = load(caminho_completo) as AudioStream
					
					if audio and not lista_sfx.has(audio):
						lista_sfx.append(audio)
						
			nome_arquivo = dir.get_next()
		dir.list_dir_end()

func _on_sprout_pressed(event: InputEvent) -> void:
	
	if not pode_tocar:
		return
	
	if lista_sfx.is_empty():
		print("Nenhum SFX encontrado em res://assets/sfx/")
		return
		
	var novo_indice = randi() % lista_sfx.size()
	while novo_indice == ultimo_indice and lista_sfx.size() > 1:
		novo_indice = randi() % lista_sfx.size()
		
	ultimo_indice = novo_indice
	
	self.pitch_scale = randf_range(0.95, 1.05)
	self.stream = lista_sfx[novo_indice]
	self.play()
	delay_curto(0.15)

func delay_curto(tempo: float) -> void:
	pode_tocar = false
	var timer = get_tree().create_timer(tempo)
	await timer.timeout
	pode_tocar = true
