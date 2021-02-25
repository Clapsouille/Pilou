extends Camera2D


onready var dernierePosition = $".".get_pos()


func _ready():
	var canvas_transform = get_viewport().get_canvas_transform()
