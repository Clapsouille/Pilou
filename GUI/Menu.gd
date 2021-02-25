extends Node2D

var screen_size
var window_size

var niveaux = {"buttes": "res://niveaux/Niveau0.tscn"}
var fondIntro = preload("res://media/menu/fond_intro.png")
var intros = {"buttes": preload("res://media/menu/buttes_intro.png")}
var niveau
var choix

# Gestion du niveau en cours
var enCours = false
var debut
var temps
var resultat


func _ready():
	screen_size = OS.get_screen_size()
	window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)


func _on_niveau_pressed(niv):
	choix = niv
	$CanvasLayer/FondIntro.texture = fondIntro
	$CanvasLayer/Intro.texture = intros[niv]
	$CanvasLayer/Contenu.hide()
	$IntroTimer.start()
	yield($IntroTimer, "timeout")
	get_tree().change_scene(niveaux[niv])


func _on_Quitter_pressed():
	get_tree().quit()
