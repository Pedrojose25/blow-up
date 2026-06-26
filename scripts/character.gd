extends CharacterBody2D

# Velocidade de movimento da nossa personagem
@export var velocidade: float = 80.0

# Referência para o nó que gerencia os sprites e as animações
# Nota: Se o seu nó na árvore ainda se chamar Sprite2D, o código abaixo funciona perfeitamente.
@onready var sprite: AnimatedSprite2D = $Sprite2D as AnimatedSprite2D

# Guarda a última direção para saber para onde ela fica olhando quando parar
var ultima_direcao: String = "baixo"

func _physics_process(_delta):
	var direcao = Vector2.ZERO
	
	# Lê os comandos padrão do teclado (Setas / WASD)
	direcao.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direcao.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Regra do Bomberman: impede movimento na diagonal
	if direcao.x != 0:
		direcao.y = 0
		
	# Se estiver se movendo, aplica a física e escolhe a animação
	if direcao != Vector2.ZERO:
		velocity = direcao.normalized() * velocidade
		atualizar_animacao(direcao)
	else:
		velocity = Vector2.ZERO
		parar_animacao()

	# Executa a movimentação travando nas colisões das paredes
	move_and_slide()

# Função que escolhe qual animação rodar baseado para onde o jogador aperta
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

# Função que para a animação no primeiro quadro quando o jogador solta o teclado
func parar_animacao():
	sprite.stop()
	# Força o frame a voltar para o estado estático parado olhando para a última direção
	sprite.animation = "andar_" + ultima_direcao
	sprite.frame = 0
