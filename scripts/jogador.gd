extends CharacterBody2D

@export var velocidade: float = 80.0

# Pré-carrega a cena da bomba para podermos criá-la no jogo
const SCENE_BOMBA = preload("res://Scenes/bomba.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ultima_direcao: String = "baixo"
var historico_input: Array[String] = []

# Distância máxima em pixels que o jogo vai te "ajudar" a deslizar na quina (ajuste se achar muito ou pouco)
const MARGEM_DESLIZE: float = 4.0


func _physics_process(_delta):
	atualizar_historico_input()
	
	# Detecta se o jogador apertou o botão de soltar bomba (Tecla Z)
	if Input.is_action_just_pressed("colocar_bomba"):
		soltar_bomba()
	
	var direcao = Vector2.ZERO
	
	if not historico_input.is_empty():
		var comando_atual = historico_input.back()
		
		match comando_atual:
			"direita": direcao.x = 1
			"esquerda": direcao.x = -1
			"baixo": direcao.y = 1
			"cima": direcao.y = -1

	if direcao != Vector2.ZERO:
		velocity = direcao.normalized() * velocidade
		atualizar_animacao(direcao)
		
		# Executa o movimento e checa se colidimos com uma quina
		var colidiu = move_and_slide()
		if colidiu:
			tentar_deslizar_na_quina(direcao)
	else:
		velocity = Vector2.ZERO
		parar_animacao()
		move_and_slide()

# Função mágica que faz o personagem "escorregar" para dentro do corredor livre
func tentar_deslizar_na_quina(dir: Vector2):
	
	# Cria uma pequena simulação de movimento para os lados para ver se desengata
	var _espaco_global = get_world_2d().direct_space_state
	
	if dir.y != 0: # Se estiver tentando andar para CIMA ou para BAIXO
		# Testa se mover um pouquinho para a direita desvia do bloco
		var query_dir = PhysicsTestMotionParameters2D.new()
		query_dir.from = global_transform
		query_dir.motion = Vector2(MARGEM_DESLIZE, dir.y * 2)
		var resultado_dir = PhysicsServer2D.body_test_motion(get_rid(), query_dir)
		
		# Testa se mover um pouquinho para a esquerda desvia do bloco
		var query_esq = PhysicsTestMotionParameters2D.new()
		query_esq.from = global_transform
		query_esq.motion = Vector2(-MARGEM_DESLIZE, dir.y * 2)
		var resultado_esq = PhysicsServer2D.body_test_motion(get_rid(), query_esq)
		
		# Se a direita estiver livre e a esquerda presa, desliza para a direita
		if not resultado_dir and resultado_esq:
			global_position.x += 1.5
		# Se a esquerda estiver livre e a direita presa, desliza para a esquerda
		elif not resultado_esq and resultado_dir:
			global_position.x -= 1.5
			
	elif dir.x != 0: # Se estiver tentando andar para a ESQUERDA ou DIREITA
		# Testa se mover um pouquinho para baixo desvia do bloco
		var query_baixo = PhysicsTestMotionParameters2D.new()
		query_baixo.from = global_transform
		query_baixo.motion = Vector2(dir.x * 2, MARGEM_DESLIZE)
		var resultado_baixo = PhysicsServer2D.body_test_motion(get_rid(), query_baixo)
		
		# Testa se mover um pouquinho para cima desvia do bloco
		var query_cima = PhysicsTestMotionParameters2D.new()
		query_cima.from = global_transform
		query_cima.motion = Vector2(dir.x * 2, -MARGEM_DESLIZE)
		var resultado_cima = PhysicsServer2D.body_test_motion(get_rid(), query_cima)
		
		if not resultado_baixo and resultado_cima:
			global_position.y += 1.5
		elif not resultado_cima and resultado_baixo:
			global_position.y -= 1.5

func atualizar_historico_input():
	if Input.is_action_just_pressed("ui_right"): historico_input.append("direita")
	if Input.is_action_just_released("ui_right"): historico_input.erase("direita")
	if Input.is_action_just_pressed("ui_left"): historico_input.append("esquerda")
	if Input.is_action_just_released("ui_left"): historico_input.erase("esquerda")
	if Input.is_action_just_pressed("ui_down"): historico_input.append("baixo")
	if Input.is_action_just_released("ui_down"): historico_input.erase("baixo")
	if Input.is_action_just_pressed("ui_up"): historico_input.append("cima")
	if Input.is_action_just_released("ui_up"): historico_input.erase("cima")

func atualizar_animacao(dir: Vector2):
	if dir.x > 0: sprite.play("andar_direita"); ultima_direcao = "direita"
	elif dir.x < 0: sprite.play("andar_esquerda"); ultima_direcao = "esquerda"
	elif dir.y > 0: sprite.play("andar_baixo"); ultima_direcao = "baixo"
	elif dir.y < 0: sprite.play("andar_cima"); ultima_direcao = "cima"

func parar_animacao():
	sprite.stop()
	sprite.animation = "andar_" + ultima_direcao
	sprite.frame = 0

# Nova função: Cria a bomba centralizada no grid de 16x16
func soltar_bomba():
	var bomba = SCENE_BOMBA.instantiate()
	
	# Em vez de usar a posição do jogador, usamos o centro real do CollisionShape2D (seus pés!)
	var posicao_pes = $CollisionShape2D.global_position
	
	# MATEMÁTICA DO GRID:
	# Pega o centro da colisão dos pés, divide por 16, arredonda para baixo e volta para pixels
	var posicao_grid = (posicao_pes / 16.0).floor() * 16.0
	
	# Centraliza a bomba no meio desse bloco do grid
	bomba.global_position = posicao_grid + Vector2(8, 8)
	
	# Adiciona a bomba na cena do jogo
	get_parent().add_child(bomba)
