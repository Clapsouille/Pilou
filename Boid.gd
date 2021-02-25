extends KinematicBody2D

var minX
var maxX
var minY
var maxY
var pos
var velocity
onready var steering = get_node("../../")
var force = Vector2.ZERO


func _ready():
	velocity = Vector2.ZERO

func _physics_process(_delta):
	move_and_slide(velocity * steering.max_speed)
	pos = get_global_position()
	check_boundaries()


func check_boundaries():
	if pos.x > maxX:
		set_global_position(Vector2(maxX, pos.y))
	elif pos.x < minX:
		set_global_position(Vector2(minX, pos.y))

	if pos.y > maxY:
		set_global_position(Vector2(pos.x, maxY))
	elif pos.y < minY:
		set_global_position(Vector2(pos.x, minY))
