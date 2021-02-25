extends KinematicBody2D

signal touche
signal destination_atteinte

# Caractéristiques de l'ennemi
var promeneur = false
var femme

# Sons de réaction
var sonsHomme = {"aww": [preload("res://media/ennemi/aww_homme1.wav"), preload("res://media/ennemi/aww_homme2.wav")],
 "bah": [preload("res://media/ennemi/bah_homme1.wav")]}
var sonsFemme = {"aww": [preload("res://media/ennemi/aww_femme1.wav"), preload("res://media/ennemi/aww_femme2.wav")],
 "bah": [preload("res://media/ennemi/bah_femme1.wav")]}

# Vitesse et déplacement de l'ennemi
export var vitesseChasse = 150
var velocityChasse = Vector2(vitesseChasse, 0)
var tabVitesses = [0, 60, 90, 120]
var vitesse
var velocity
export var rotationSpeed = PI / 50

# Repérage de Pilou
var pilou
var route_vers_pilou # Navigation path quand Pilou est repéré
var pilou_en_vue = false # Pilou est dans la zone de vision
var vers_pilou = false # Pilou est repéré : l'ennemi cherche à le rejoindre
					# tant qu'il est dans sa zone de vue et 5 secondes après qu'il en est sorti
var obstacle = false # S'il y a un obstacle devant Pilou
var caresse_pilou = false # Pilou est dans la zone de caresse de l'ennemi
var a_touche = false # L'ennemi a déjà touché Pilou et ne peut donc plus le contaminer
					# au cours des deux dernières secondes
var fait_une_pause = false # L'ennemi s'arrête un moment

# Navigation
var navigation
var ray
var destination = Vector2()
var route_a_suivre = PoolVector2Array()

# Références
var bulle = "Node2D/bulle"

##################################################
#	DEBUG
# var line
##################################################


func _ready():
	# Initialisation aléatoire de la vitesse de l'ennemi
	vitesse = tabVitesses[rand_range(0, tabVitesses.size()-1)]
	velocity = Vector2(vitesse, 0)
	if vitesse == 0:
		promeneur = false
		changer_animation("idle")
	else:
		promeneur = true
		changer_animation("run")
	# Initialisation aléatoire du sexe
	var sexe = randi()%2
	if sexe == 0:
		femme = true
	else:
		femme = false


func _physics_process(delta):
	if pilou_en_vue:
		# On caste un ray entre l'ennemi et Pilou pour vérifier si ce dernier est derrière un obstacle
		ray = get_world_2d().direct_space_state.intersect_ray(position, pilou.position, [self])
		if ray["collider"] == pilou: # Si pas d'obstacle, Pilou est repéré
			if !vers_pilou: # S'il s'agit de la première fois que l'ennemi repère Pilou
				var son = son_aleatoire("aww")
				$Son.stream = son
				$Son.play()
			vers_pilou = true

	if vers_pilou: # Pilou est repéré
		if ray["collider"] != pilou: # S'il y a un obstacle, on l'évite
			route_vers_pilou = navigation.get_simple_path(position, pilou.position)
			##################################################
			#	DEBUG
			# line.set_points(route_vers_pilou)
			# line.show()
			##################################################
			if route_vers_pilou.size() >= 2:
				regarder(route_vers_pilou[1])
		else: # Sinon, on suit Pilou
			regarder(pilou.position)
		move_and_slide(velocityChasse.rotated(rotation))
			##################################################
			#	DEBUG
#		if !fait_une_pause and !caresse_pilou:
#			if $AnimationPlayer.current_animation != "run":
#				changer_animation("run")
			##################################################

	else: # Si Pilou n'est pas répéré, l'ennemi suit sa route habituelle
		if promeneur:
			if route_a_suivre.size() >= 2:
				regarder(route_a_suivre[1])
				if position.distance_to(route_a_suivre[1]) <= vitesse*delta:
					route_a_suivre.remove(1)
			if route_a_suivre.size() < 2 or position.distance_to(destination) <= vitesse*delta:
				emit_signal("destination_atteinte", self)
			move_and_slide(velocity.rotated(rotation))


func regarder(pos): # Look_at progressif
	var angle = self.get_angle_to(pos)
	var pas_rotation = rotationSpeed
	if (abs(angle) < pas_rotation):
		pas_rotation = angle
	elif angle < 0:
		pas_rotation = -pas_rotation
	rotate(pas_rotation)
	get_node(bulle).rotate(-pas_rotation)  # pour que la bulle soit toujours orientée vers le haut


func _on_Vue_Ennemi_body_entered(body):
	if body.name == "Pilou":
		pilou = body
		pilou_en_vue = true
		$OuEstPilouTimer.stop()
		$PilouPerduTimer.stop()
		changer_bulle("j'aime pilou")


func _on_Vue_Ennemi_body_exited(body):
	if body.name == "Pilou":
		pilou_en_vue = false
		$OuEstPilouTimer.start()


func _on_OuEstPilouTimer_timeout():
	# L'ennemi s'arrête et regarde autour de lui pendant un bref instant
	var vel_habituelle = velocity
	velocity = Vector2(0,0)
	fait_une_pause = true
	changer_animation("idle")
	changer_bulle("pilou a disparu")
	$Son.stream = son_aleatoire("bah")
	$Son.play()
	$PilouPerduTimer.start()
	yield($PilouPerduTimer, "timeout")
	# Puis il reprend son comportement habituel
	vers_pilou = false
	fait_une_pause = false
	emit_signal("destination_atteinte", self)
	velocity = vel_habituelle
	if promeneur:
		changer_animation("run")
	else:
		changer_animation("idle")
	changer_bulle("rien")


func _on_Portee_Bras_body_entered(body):
	if body.name == "Pilou":
		caresse_pilou = true
		changer_animation("bellyrub")
		if !a_touche:
			emit_signal("touche")
		a_touche = true
		$InfectionTimer.start()


func _on_Portee_Bras_body_exited(body):
	if body.name == "Pilou":
		caresse_pilou = false
		changer_animation("run")


func changer_animation(anim):
	$AnimationPlayer.play("transition")
	$AnimationPlayer.queue(anim)


func changer_bulle(etat): # Affichage de l'infobulle en fonction de l'état de l'ennemi
	if etat == "rien":
		get_node(bulle).visible = false
	else:
		get_node(bulle).visible = true
		if etat == "pilou a disparu":		
			get_node(bulle+"/promenade").visible = false
			get_node(bulle+"/pilou").visible = true
			get_node(bulle+"/pilou/coeur").visible = false
			get_node(bulle+"/pilou/question").visible = true
		elif etat == "j'aime pilou":		
			get_node(bulle+"/promenade").visible = false
			get_node(bulle+"/pilou").visible = true
			get_node(bulle+"/pilou/coeur").visible = true
			get_node(bulle+"/pilou/question").visible = false


func son_aleatoire(reaction): # Son aléatoire en fonction du sexe et de la réaction
	var son
	if femme:
		var num = randi()%len(sonsFemme[reaction])
		son = sonsFemme[reaction][num]
	else:
		var num = randi()%len(sonsHomme[reaction])
		son = sonsHomme[reaction][num]
	return son


func _on_InfectionTimer_timeout(): # Après 2 secondes, l'ennemi peut de nouveau contaminer Pilou
	a_touche = false
