extends CanvasLayer


func _on_Rejouer_pressed():
	get_tree().change_scene("res://niveaux/Niveau0.tscn")


func _on_Retour_pressed():
	get_tree().change_scene("res://GUI/Menu.tscn")


func fin_du_jeu(gagne):
	if gagne:
		$Popup/TextureRect.texture = load("res://media/menu/menu_fin_gagne.png")
	else:
		$Popup/TextureRect.texture = load("res://media/menu/menu_fin_perdu.png")
	$Popup.popup()
