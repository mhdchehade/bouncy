extends Node2D

const c = preload("res://c.tscn")

var pn
var up = true
var pn2
var up2 = true
var pn3
var up3 = true
func _ready():
	randomize()
	pn = rand_range(0.0,1.0)
	pn2 = rand_range(0.0,1.0)
	pn3 = rand_range(0.0,1.0)
	set_process(true)

func color():
	if pn > 1:
		up = false
	if pn < 0:
		up = true
		
	if pn2 > 1:
		up2 = false
	if pn2 < 0:
		up2 = true
		
	if pn3 > 1:
		up3 = false
	if pn3 < 0:
		up3 = true
	
	if up:
		pn += rand_range(0.0001,0.0005)
		if rand_range(0.0,1.0) > 0.99:
			up = false
	else:
		pn -= rand_range(0.0001,0.0005)
		if rand_range(0.0, 1.0) > 0.99:
			up = true
	
	if up2:
		pn2 += rand_range(0.0001,0.0005)
		if rand_range(0.0,1.0) > 0.99:
			up2 = false
	else:
		pn2 -= rand_range(0.0001,0.0005)
		if rand_range(0.0, 1.0) > 0.99:
			up2 = true

	if up3:
		pn3 += rand_range(0.0001,0.0005)
		if rand_range(0.0,1.0) > 0.99:
			up3 = false
	else:
		pn3 -= rand_range(0.0001,0.0005)
		if rand_range(0.0, 1.0) > 0.99:
			up3 = true
	VisualServer.set_default_clear_color(Color(pn,pn2,pn3))

func _draw():
	randomize()
	
	var center = Vector2(rand_range(0,1000), rand_range(0,500))
	var radius = floor(rand_range(0.1, 1.9))
	var color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	var colora = Color(0, 0, 0, 0)
	var dot = c.instance()
	var sprite = dot.get_node("./dot")
	add_child(dot)
	sprite.set_pos(center)
	dot.get_node("./dot/dots").set_modulate(color)
	dot.get_node("./dot/Trail2D").set_draw_behind_parent(true)
	dot.get_node("./dot/Trail2D").startColor = color
	dot.get_node("./dot/Trail2D").endColor = colora
	

var time = 0
func _process(delta):
	color()
	time += delta
	if time > 1.5:
		update()
		time = 0

