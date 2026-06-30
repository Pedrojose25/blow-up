extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $TimerExplosao

func _ready():
	# Inicia a animação de piscar e o cronômetro da explosão
	sprite.play("piscando")
	timer.start()

# O Godot avisa quando o tempo do Timer acabar
func _on_timer_explosao_timeout():
	# Aqui vai entrar o código que cria o fogo/explosão cruzada nas 4 direções
	print("BOOM!") 
	queue_free() # Remove a bomba do mapa
