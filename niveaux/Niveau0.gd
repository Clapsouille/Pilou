extends Node2D

signal chgmt	# Modifications à apporter aux informations du HUD
signal gel_vide	# Quand un gel a été utilisé

var screen_size

# Dictionnaire de tiles
var tiles = {"eau": [12,13,14,15,16,17,18,19,20,22,23,24,25], 
"chemin": [0,1,2,3,4,5,6,7,8,9,10,11,26,27,28,29,30,31], "herbe": [21]}

# Déplacement Pilou
export var speedChemin = 400
export var speedHerbe = 200
var velocityVariation = speedChemin/speedHerbe
var surChemin = true

# Infection Pilou
var limiteInfection = 5
var infectionMax = 10

# Limites du niveau
export var borderLeft = -6000
export var borderRight = 7800
export var borderTop = -3000
export var borderBottom = 5600

# Ennemis et gels
var Gel = load("res://objets/Gel.tscn")
var Ennemi = load("res://personnages/Ennemi.tscn")
export var nombre_ennemis = 15
var ennemis = []
export var nombre_gels = 100
var gels = []

# Données du HUD
var infosPilou = {"infection": 0}


func _ready():
	screen_size = get_viewport_rect().size
	
	# Préparation de la navmesh
	$Navigation2D.obstacles = $Obstacles
	
	# Réglage des collision layer/mask
	##################################################
	# TODO : revoir toutes ces histoires de layer/maks
	##################################################
	for banc in $Obstacles/Bancs.get_children():
		banc.set_collision_layer_bit(3, true)

	# Clamping de Pilou et de la caméra
	$Pilou.pilou_clamp = true
	$Pilou.limite_droite = borderRight
	$Pilou.limite_gauche = borderLeft
	$Pilou.limite_basse = borderBottom
	$Pilou.limite_haute = borderTop
	$Pilou/Camera2D.limit_left = borderLeft
	$Pilou/Camera2D.limit_right = borderRight
	$Pilou/Camera2D.limit_bottom = borderBottom
	$Pilou/Camera2D.limit_top = borderTop
	
	# Génération des gels hydroalcooliques
	randomize()
	for i in range (nombre_gels):
		gels.append(Gel.instance())
		add_child(gels[i])
		gels[i].position = position_aleatoire()
		# Connexion aux gels
		$Pilou/Area2D.connect("area_shape_entered", gels[i], "_on_Pilou_area_shape_entered")
		gels[i].connect("presse", self, "_on_Pilou_sur_gel")
		self.connect("gel_vide", gels[i], "_on_gel_vide")

	# Attente avant de lancer le jeu
	$StartTimer.start()
	$Pilou.pause = true
	$Pilou.speed = 0
	$Pilou.velocity = Vector2.ZERO
	$HUD.infos = infosPilou
	$HUD/MarginContainer.show()
	yield($StartTimer, "timeout")
	
	# On lance Pilou
	$HUD.lancer_jeu()
	$Pilou.go()
	$Pilou.speed = speedChemin
	$Pilou.velocity = Vector2(speedChemin, 0)


func position_aleatoire():
	var pos = Vector2(rand_range(borderLeft, borderRight), rand_range(borderTop, borderBottom))
	# Vérifier que la position est dans la zone navigable
	while $TileMap.get_cellv($TileMap.world_to_map(pos)) in tiles["eau"]:
			pos.x = rand_range(borderLeft, borderRight)
			pos.y = rand_range(borderTop, borderBottom)
	return pos


func _process(delta):
	var ouEstPilou = $TileMap.world_to_map($Pilou.position)
	if $TileMap.get_cellv(ouEstPilou) in tiles["chemin"] and !surChemin:
		$Pilou.speed*=velocityVariation
		$Pilou.velocity*=velocityVariation
		$Pilou/AnimatedSprite.animation = "course"
		surChemin = true
	if surChemin:
		if $TileMap.get_cellv(ouEstPilou) in tiles["chemin"] :
			pass
		else:
			$Pilou.speed/=velocityVariation
			$Pilou.velocity/=velocityVariation
			$Pilou/AnimatedSprite.animation = "marche"
			surChemin = false


func changer_destination(ennemi):
	var pos = position_aleatoire()
	ennemi.destination = pos
	ennemi.route_a_suivre = $Navigation2D.get_simple_path(ennemi.position, ennemi.destination)
##################################################
#	DEBUG
# ennemi.line.set_points(ennemi.route_a_suivre)
# ennemi.line.show()
##################################################


func _on_Pilou_touche():
	if $Pilou.infection < 10:
		$Pilou.infection += 1
		emit_signal("chgmt", "infection", $Pilou.infection)
		if $Pilou.infection == 5:
			$Pilou.devient_contagieux()


func _on_Pilou_sur_gel(bouteille):
	if $Pilou.infection > 0:
		$Pilou.infection -= 1
		emit_signal("gel_vide", bouteille)
		emit_signal("chgmt", "infection", $Pilou.infection)
		if $Pilou.infection == 4:
			$Pilou.devient_non_contagieux()


func _on_gagne():
	$Pilou.stop()
	$FinTimer.start()
	yield($FinTimer, "timeout")
	$Menu_Fin.fin_du_jeu($Pilou.infection < 5)


func _on_navigation_prete():
	# Génération des ennemis
	randomize()
	for i in range (nombre_ennemis):
		ennemis.append(Ennemi.instance())
		add_child(ennemis[i])
		# Réglage des collision layer/mask
		ennemis[i].set_collision_layer_bit(2, true)
		ennemis[i].set_collision_mask_bit(0, true)
		ennemis[i].set_collision_mask_bit(1, true)
		ennemis[i].set_collision_mask_bit(2, true)
		ennemis[i].set_collision_mask_bit(3, true)
		# Propriétés de l'ennemi
		ennemis[i].position = position_aleatoire()
		if ennemis[i].promeneur:
			ennemis[i].destination = position_aleatoire()
			ennemis[i].route_a_suivre = $Navigation2D.get_simple_path(ennemis[i].position, ennemis[i].destination)
		ennemis[i].navigation = $Navigation2D
		# Connexion aux enemmis
		ennemis[i].connect("touche", self, "_on_Pilou_touche")
		ennemis[i].connect("destination_atteinte", self, "changer_destination")
##################################################
#	DEBUG
# ennemis[i].line = Line2D.new()
# add_child(ennemis[i].line)
# ennemis[i].line.set_points(ennemis[i].route_a_suivre)
# ennemis[i].line.show()
##################################################
