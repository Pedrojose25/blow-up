extends Area2D

const SCENE_EXPLOSAO = preload("res://Scenes/explosao.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $TimerExplosao

@export var alcance: int = 1

func _ready():
	# Alinha a bomba perfeitamente no centro do tile de 16x16 mais próximo
	alinhar_ao_grid()
	sprite.play("piscando")
	timer.start()

func alinhar_ao_grid():
	# Descobre o centro do bloco de 16x16 mais próximo matematicamente
	var grid_x = floor(global_position.x / 16.0) * 16.0 + 8.0
	var grid_y = floor(global_position.y / 16.0) * 16.0 + 8.0
	global_position = Vector2(grid_x, grid_y)

func _on_timer_explosao_timeout():
	executar_explosao()
	queue_free()

func executar_explosao():
	# 1. Cria o centro da explosão
	criar_fogo(global_position, "centro", 0.0)
	
	# Mapeamento clássico de direções e rotações em graus
	var direcoes = {
		Vector2.RIGHT: 0.0,
		Vector2.DOWN: 90.0,
		Vector2.LEFT: 180.0,
		Vector2.UP: 270.0
	}
	
	var espaco_fisico = get_world_2d().direct_space_state
	
	# 2. Espalha o fogo nas 4 direções
	for dir in direcoes.keys():
		var rotacao = direcoes[dir]
		
		for i in range(1, alcance + 1):
			var nova_posicao = global_position + (dir * i * 16.0)
			
			# Cria query física para checar se há uma parede indestrutível na Layer 2
			var query = PhysicsPointQueryParameters2D.new()
			query.position = nova_posicao
			query.collision_mask = 2 # Filtra apenas para colidir com Paredes Indestrutíveis
			
			var colisoes = espaco_fisico.intersect_point(query)
			
			if not colisoes.is_empty():
				# Se bateu na parede, para de desenhar fogo nesta direção
				break
				
			var tipo = "ponta" if i == alcance else "meio"
			criar_fogo(nova_posicao, tipo, rotacao)

func criar_fogo(posicao: Vector2, tipo: String, rotacao: float):
	var fogo = SCENE_EXPLOSAO.instantiate()
	fogo.global_position = posicao
	get_parent().add_child(fogo)
	fogo.inicializar(tipo, rotacao)
