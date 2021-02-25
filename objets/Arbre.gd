extends Area2D


func _on_Feuillage_body_entered(body):
	if body.name == "Pilou":
		$Feuillage/Sprite.modulate.a = 0.5


func _on_Feuillage_body_exited(body):
	if body.name == "Pilou":
		$Feuillage/Sprite.modulate.a = 1
