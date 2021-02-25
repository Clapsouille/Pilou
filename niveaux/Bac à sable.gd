extends Node2D

signal chgmt
signal gel_vide
signal fin

var screen_size

# Dictionnaire de tiles
var tiles = {"herbe": 0, "chemin": 1, "eau": 2}

# Déplacement Pilou
export var speedChemin = 400
export var speedHerbe = 200
var velocityVariation = speedChemin/speedHerbe
var surChemin = true

# Infection Pilou
var limiteInfection = 1
var infectionMax = 10

# Limites du niveau
export var borderLeft = -1200
export var borderRight = 1200
export var borderTop = -200
export var borderBottom = 1200

# Ennemis et gels
export var nombre_ennemis = 15
var ennemis = []
export var nombre_gels = 5
var gels = []

# Données du HUD
var infosPilou = {"infection": 0}


func _ready():
	screen_size = get_viewport_rect().size
		
	$Obstacles/Banc.set_collision_layer_bit(3, true)
	$Obstacles/Banc/Pieds.set_collision_layer_bit(1, true)
	
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
	
	# Préparation du flocking
	$Flocking.pilou = $Pilou
	$Flocking.minX = borderLeft+50
	$Flocking.maxX = borderRight-50
	$Flocking.minY = borderTop+50
	$Flocking.maxY = borderBottom-50
	for b in $Flocking.boid_array:
		b.set_collision_layer_bit(1, true)
		b.set_collision_mask_bit(0, true)
	
	# Préparation de la navmesh
	$Navigation2D.obstacles = $Obstacles
	
	# Génération des ennemis
	var Ennemi = load("res://personnages/Ennemi.tscn")
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
		ennemis[i].regarder(position_aleatoire())
		ennemis[i].position = position_aleatoire()
		if ennemis[i].promeneur:
			ennemis[i].destination = position_aleatoire()
			ennemis[i].route_a_suivre = $Navigation2D.get_simple_path(ennemis[i].position, ennemis[i].destination)
		# Connexion aux enemmis
		ennemis[i].connect("touche", self, "_on_Pilou_touche")
		ennemis[i].connect("destination_atteinte", self, "changer_destination")
		ennemis[i].navigation = $Navigation2D
		
	# Génération des gels hydroalcooliques
	var Gel = load("res://objets/Gel.tscn")
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
	yield($StartTimer, "timeout")
	
	# On lance Pilou
	$Pilou.pause = false
	$Pilou.speed = speedHerbe
	$Pilou.velocity = Vector2(speedHerbe, 0)
	

func position_aleatoire():
	var pos = Vector2(rand_range(borderLeft, borderRight), rand_range(borderTop, borderBottom))
	# Vérifier que la position est dans la zone navigable
	while $Navigation2D/Tilemap.get_cellv($Navigation2D/Tilemap.world_to_map(pos)) == tiles["eau"]:
			pos.x = rand_range(borderLeft, borderRight)
			pos.y = rand_range(borderTop, borderBottom)
	return pos
	

func changer_destination(ennemi):
	var pos = position_aleatoire()
	ennemi.destination = pos
	ennemi.route_a_suivre = $Navigation2D.get_simple_path(ennemi.position, ennemi.destination)


func _process(_delta):
	var ouEstPilou = $Navigation2D/Tilemap.world_to_map($Pilou.position)
	if $Navigation2D/Tilemap.get_cellv(ouEstPilou) == tiles["chemin"] and !surChemin:
		$Pilou.speed*=velocityVariation
		$Pilou.velocity*=velocityVariation
		$Pilou/AnimatedSprite.animation = "course"
		surChemin = true
	if $Navigation2D/Tilemap.get_cellv(ouEstPilou) != tiles["chemin"] and surChemin:
		$Pilou.speed/=velocityVariation
		$Pilou.velocity/=velocityVariation
		$Pilou/AnimatedSprite.animation = "marche"
		surChemin = false


func _on_Pilou_touche():
	if $Pilou.infection < 10:
		$Pilou.infection += 1
		emit_signal("chgmt", "infection", $Pilou.infection)


func _on_Pilou_sur_gel(bouteille):
	if $Pilou.infection > 0:
		$Pilou.infection -= 1
		emit_signal("gel_vide", bouteille)
		emit_signal("chgmt", "infection", $Pilou.infection)


func _on_gagne():
	$FinTimer.start()
	yield($FinTimer, "timeout")
	$Pilou.velocity = Vector2.ZERO
	if $Pilou.infection < 5:
		$Pilou/AnimatedSprite.animation = "arrive"
		emit_signal("fin", "gagne")
	else:
		$Pilou/AnimatedSprite.animation = "arrive_covid"
		emit_signal("fin", "perdu")

