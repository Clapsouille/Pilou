extends Node2D

var window

var max_speed = 15
var max_force = 1
var minX
var maxX
var minY
var maxY
var population = 20
var comfort_zone = 100
var field_of_view = 0 #180°
var target_radius = 400
var brake_radius = 250

var cohesion_factor = 1.5
var alignment_factor = 1
var separation_factor = 1.5

const PIXEL_RADIUS = 3

var current_boid
var vel
var acc
var steer
var pos
var dir
var pilou
var target

var boidscene = preload("res://Boid.tscn")
var boid_array = []
var flockmates = []
onready var nest = $Nest


func _ready():
	window = OS.get_window_size()


func _on_Niveau_ready():
	for _i in range(population):
		randomize()
		_create_boid(randf()*window.x, randf()*window.y)


func _physics_process(_delta):
	for boid in boid_array:
		current_boid = boid
		_get_variables(boid)
		calc_master(boid)
		if steer != Vector2.ZERO:
			apply_forces()
			boid.velocity = vel.clamped(max_speed)
			#boid.velocity = vel.clamped(max_speed*brake())
		update()
	

func _create_boid(x, y):
	var b = boidscene.instance()
	b.minX = minX
	b.maxX = maxX
	b.minY = minY
	b.maxY = maxY
	b.set_global_position(Vector2(x, y))
	boid_array.append(b)
	nest.add_child(b)


func _get_variables(boid):
	pos = boid.get_global_position()
	vel = boid.velocity
	dir = vel.angle()
	acc = Vector2.ZERO
	steer = Vector2.ZERO
	target = pilou.get_global_position()
	flockmates = get_flockmates(boid)
	
	
func get_flockmates(boid):
	var fm = []
	for b in boid_array:
		var bpos = b.get_global_position()
		if pos.distance_to(bpos) <= comfort_zone && pos.distance_to(bpos) > 0:
			var nbdir = (bpos - pos).normalized()
			if nbdir.dot(vel.normalized()) >= field_of_view:
				if b != null:
					fm.append(b)
	return fm


func calc_master(boid):
	calc_seek()
	boid.rotation = dir - PI/2
#	boid.rotation = (target - pos).angle()-PI/2
	
	if flockmates && !flockmates.empty():
		calc_separation()
		calc_cohesion()
		calc_alignment()


func calc_seek():
	if pos.distance_to(target) < target_radius:
		acc = (target-pos).normalized() * max_speed
		steer -= acc-vel


func calc_separation():
	var average = Vector2.ZERO
	for f in flockmates:
		average += f.get_global_position() - pos
	average /= flockmates.size()
	acc = -average
	steer += acc*separation_factor


func calc_cohesion():
	var average = Vector2.ZERO
	for f in flockmates:
		average += f.get_global_position() - pos
	average /= flockmates.size()
	acc = average
	steer += acc * cohesion_factor


func calc_alignment():
	var average = Vector2.ZERO
	for f in flockmates:
		average += f.velocity
	average /= flockmates.size()
	acc = average
	steer += acc * alignment_factor


func apply_forces():
	current_boid.force = steer
	vel+= steer.clamped(max_force)


#func brake():
#	if pos.distance_to(target) < brake_radius:
#		if pos.distance_to(target) < PIXEL_RADIUS:
#			return 0
#		else:
#			return pos.distance_to(target) / brake_radius
#	else:
#		return 1


