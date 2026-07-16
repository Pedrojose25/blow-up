extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Garante que vai sumir quando a animação terminar
	sprite.animation_finished.connect(_on_animation_finished)

# Função direta e sem mistério para configurar o fogo
func inicializar(tipo_animacao: String, angulo: float):
	sprite.play(tipo_animacao)
	sprite.rotation_degrees = angulo
	
func _on_animation_finished():
	queue_free()
