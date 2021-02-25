extends Navigation2D

signal prete

var bordsNiveau
var obstacles


func get_NavigationPolygonInstances(node, tab):
	# Parcours des obstacles et ajout des navigation polygones à tab
	if node.get_class() == "NavigationPolygonInstance":
		tab.append(node)
	for c in node.get_children():
		get_NavigationPolygonInstances(c, tab)

	
func _on_Niveau_ready():
	var nav = $Navmesh.navpoly
	
	##################################################
	# Dessin des bords du niveau si choix de le faire par script
	##################################################
#	nav.add_outline(bordsNiveau)
#	nav.make_polygons_from_outlines()
#	$Navmesh.enabled = false
#	$Navmesh.enabled = true
	
	# Adaptation et ajout des navigation poygones des obstacles à la navmesh
	var tab = []
	get_NavigationPolygonInstances(obstacles, tab)
	for object in tab:
		var new_polygon = PoolVector2Array([])
		var pol = object.navpoly.get_vertices()
		for vector in pol:
			vector *= object.get_parent().scale
			##################################################
			# TODO : Rotation à revoir
#			vector.rotated(object.get_parent().rotation)
#			if(object.get_parent().rotation<-30):
#			print (object.get_parent().name," est tourné :",object.get_parent().rotation)
			##################################################
			new_polygon.append(vector + object.global_position)
		nav.add_outline(new_polygon)
		nav.make_polygons_from_outlines()
	
	# Update de la navmesh
	$Navmesh.enabled = false
	$Navmesh.enabled = true
	
	emit_signal("prete")
