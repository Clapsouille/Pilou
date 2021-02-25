extends Area2D

signal presse


func _ready():
	$AnimatedSprite.animation = "gel_normal"


func _on_Pilou_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area == self:
		emit_signal("presse", self)
		

func _on_gel_vide(bouteille):
	if bouteille == self:
		$AnimatedSprite.play("gel_pscht")
		$Particles2D.emitting = true
		yield($AnimatedSprite, "animation_finished")
		queue_free()
