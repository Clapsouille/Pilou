extends KinematicBody2D

var screen_size

# Vitesse et déplacement
export var rotation_speed = PI / 50
var speed = 50
var velocity = Vector2(speed, 0)
var limite_droite
var limite_gauche
var limite_haute
var limite_basse
var pilou_clamp

# Autres propriétés
var infection = 0
var pause = true


func _ready():
	screen_size = get_viewport_rect().size
	Main.set("Pilou", self)
	$AnimatedSprite.animation = "pause"
	$CollisionShape2D.disabled = true
	

func _physics_process(_delta):
	if Input.is_action_pressed("ui_right") and !pause:
		rotation += rotation_speed
		velocity = velocity.rotated(rotation_speed)
	if Input.is_action_pressed("ui_left") and !pause:
		rotation -= rotation_speed
		velocity = velocity.rotated(-rotation_speed)

	$AnimatedSprite.play()
	
	move_and_slide(velocity)

	if pilou_clamp:
		position.x = clamp(position.x, limite_gauche-20, limite_droite-20)
		position.y = clamp(position.y, limite_haute-20, limite_basse-20)


func go():
	pause = false
	$AnimatedSprite.animation = "course"
	$CollisionShape2D.disabled = false


func stop():
	pause = true
	velocity = Vector2.ZERO
	$AnimatedSprite.animation = "pause"
	$CollisionShape2D.disabled = true


func devient_contagieux():
	$Covid_Particles.emitting = true
	
func devient_non_contagieux():
	$Covid_Particles.emitting = false
