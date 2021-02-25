extends Node2D

signal jouer

var screen_size
var window_size

var niveaux = {"buttes": preload("res://niveaux/Niveau0.tscn")}
var intro
var menu
var niveau
var choix

# Gestion du niveau en cours
var enCours = false
var debut
var temps
var resultat


func _ready():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	menu = load("res://GUI/Menu.tscn").instance()
	add_child(menu)
	menu.connect("charger", self, "_on_charger_niveau")
	self.connect("jouer", menu, "_on_jouer")
	intro = load("res://GUI/Intro.tscn").instance()


func _process(delta):
	if enCours:
		temps = OS.get_system_time_msecs() - debut
		$HUD.temps = temps


func _on_fin_niveau(res):
	enCours = false
	resultat = res
	$Menu_Fin/Popup.popup_centered()


func _on_charger_niveau(niv):
	choix = niv
	emit_signal("jouer")
	menu.queue_free()
	add_child(intro)
	intro.lancer(niv)
	$MenuTimer.start()
	yield($MenuTimer, "timeout")
	intro.queue_free()
	lancer_niveau()
	
	
func lancer_niveau():
	niveau = niveaux[choix].instance()
	add_child(niveau)
	$HUD.initialisation_HUD(niveau.infosPilou)
	niveau.connect("fin", self, "_on_fin_niveau")
	niveau.connect("chgmt", $HUD, "_on_niveau_chgmt")
	niveau.connect("fin", $HUD, "_on_niveau_fin")
	$Menu_Fin.connect("rejouer", self, "_on_rejouer")
	$Menu_Fin.connect("menu", self, "_on_menu")
	enCours = true
	$HUD/MarginContainer.show()
	debut = OS.get_system_time_msecs()

	
func _on_rejouer():
	niveau.queue_free()
	lancer_niveau()
		
	
func _on_menu():
	niveau.queue_free()
	menu = add_child(load("res://GUI/Menu.tscn").instance())
	#connect("charger", self, "_on_charger_niveau")
