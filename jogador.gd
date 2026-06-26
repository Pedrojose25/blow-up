extends CharacterBody2D

@export var velocidade: float = 80.0

# Procura o nó exatamente com o nome da tua árvore
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ultima_direcao: String = "baixo"

func _physics_process(_delta):
	var direcao = Vector2.ZERO
	
	direcao.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direcao.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Regra do Bomberman: impede movimento na diagonal
	if direcao.x != 0:
		direcao.y = 0
		
	if direcao != Vector2.ZERO:
		velocity = direcao.normalized() * velocidade
		atualizar_animacao(direcao)
	else:
		velocity = Vector2.ZERO
		parar_animacao()

	move_and_slide()

func atualizar_animacao(dir: Vector2):
	if dir.x > 0:
		sprite.play("andar_direita")
		ultima_direcao = "direita"
	elif dir.x < 0:
		sprite.play("andar_esquerda")
		ultima_direcao = "esquerda"
	elif dir.y > 0:
		sprite.play("andar_baixo")
		ultima_direcao = "baixo"
	elif dir.y < 0:
		sprite.play("andar_cima")
		ultima_direcao = "cima"

func parar_animacao():
	sprite.stop()
	# Se quiseres usar a animação "parado" que criaste, podes usar a linha abaixo:
	# sprite.play("parado")
	# Ou a lógica clássica que reaproveita o primeiro frame da caminhada:
	sprite.animation = "andar_" + ultima_direcao
	sprite.frame = 0
