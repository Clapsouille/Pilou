extends CanvasLayer

var infos = {}
var enJeu = false

var debut
var temps = 0

# Barre d'infection
onready var barre = $MarginContainer/VBoxContainer/Infection/TextureProgress
var infectionOk = preload("res://media/HUD/barre_infection_remplissage.png")
var infectionDanger = preload("res://media/HUD/barre_infection_remplissage_covid.png")


func _ready():
	$MarginContainer.hide()


func _process(delta):
	if enJeu:
		temps = OS.get_system_time_msecs() - debut
		var secondes = temps / 1000
		var minutes = secondes / 60
		secondes = secondes % 60
		$MarginContainer/VBoxContainer/Temps.text = "%02d : %02d" % [minutes, secondes]


func lancer_jeu():
	enJeu = true
	debut = OS.get_system_time_msecs()


func _on_niveau_chgmt(nom, valeur):
	infos[nom] = valeur
	barre.value = infos["infection"]
	if infos["infection"] < 5:
		barre.texture_progress = infectionOk
	else:
		barre.texture_progress = infectionDanger
	##################################################
	# TODO : animation alertant sur le niveau d'infection quand >5
	##################################################


func _on_niveau_fin():
	pass
	##################################################
	# TODO
	##################################################
