tool
extends Node2D

export(Texture) var texture
export var flipH = false
export var flipV = false


export(Color) var startColor = Color()
export(Color) var endColor = Color()
var instance = Polygon2D.new()

export(bool) var emit = true
var emittingDone = false

export var lifeTime = 1.0
var lifeTimeRatio = 1.0

export var startWidth = 50
export var endWidth = 0.0

export var maxAngle = 2.0
export var minVertexDistance = 5
export var maxVertexDistance = 10
#these help make less geometry
export var optimizeAngleInterval = 0.1
export var optimizeDistanceInterval = 0.05
export var optimizeCount = 30
var optCount = 30

var points = []
var verts = []
var uvs = []
var colors = []
var pairs = []
var pointCount = 0 #just to make the lookup easier

class Point:
	var timeAlive = 0
	
	var transform = Matrix32()
	
	var vectors = [Vector2(),Vector2()]
	var uvs = [Vector2(),Vector2()]
	var color = Color()

	func set(tran = Matrix32()):
		transform = Matrix32().translated(tran.get_origin())
		

func _ready():
	set_process(true)
	add_child(instance)
	instance.set_name("TrailPolygon")
	instance.set_texture(texture)
	optCount = optimizeCount

func _process(delta):
	update_polygon(delta)
	
	
func addPoint():
	points.append(Point.new())
	points[pointCount].set(get_global_transform())
	pointCount+=1
	
func insertPoint():
	points.insert(0,Point.new());
	points[0].set(get_global_transform())
	pointCount+=1

var shape_center = Vector2()
func get_center():
	var center = Vector2()
	
	for i in range(pairs.size()):
		var o = pairs[i].vert
		center += o
	center /= pairs.size()
	shape_center = center


	
func updatePairs():
	verts = []
	uvs = []
	colors = []
	for i in range(0,pointCount-1):
		var a = points[i]
		var b = points[i+1]
		
		#tri 1
		verts.append(a.vectors[0])
		uvs.append(a.uvs[0])
		colors.append(a.color)
		
		verts.append(a.vectors[1])
		uvs.append(a.uvs[1])
		colors.append(a.color)
		
		verts.append(b.vectors[0])
		uvs.append(b.uvs[0])
		colors.append(b.color)
		
		
		verts.append(a.vectors[1])
		uvs.append(a.uvs[1])
		colors.append(a.color)
		
		verts.append(b.vectors[1])
		uvs.append(b.uvs[1])
		colors.append(b.color)
		
		verts.append(b.vectors[0])
		uvs.append(b.uvs[0])
		colors.append(b.color)
	
func update_polygon(delta):
	#emit
	if(!emit):
		emittingDone = true
	
	if(emittingDone):
		emit = false
	
	#check for dead points
	for i in range(pointCount-1,0,-1):
		var p = points[i]
		if(p == null || p.timeAlive > lifeTime):
			points.remove(i)
			pointCount-=1
		else:
			p.timeAlive += delta
	
	#optomize
	if(pointCount > optCount):
		maxAngle += optimizeAngleInterval
		maxVertexDistance += optimizeDistanceInterval
		optCount += 1
	elif(pointCount < optimizeCount && optCount > optimizeCount):
		maxAngle -= optimizeAngleInterval
		maxVertexDistance -= optimizeDistanceInterval
		optCount -= 1
	
	#add new points
	if(emit):
		if(pointCount == 0):
			addPoint()
			addPoint()
		if(pointCount == 1):
			insertPoint()
		
		var add = false
		var sqrDistance = points[1].transform.get_origin().distance_squared_to(get_global_transform().get_origin())
		
		if(sqrDistance > minVertexDistance * minVertexDistance):
			if(sqrDistance > maxVertexDistance * maxVertexDistance):
				add = true
			elif( rad2deg(get_global_pos().angle_to(points[1].transform.get_origin())) > maxAngle):
				add = true
		
		if(add == true):
			insertPoint()
		else:
			var t = get_global_transform()
			points[0].set(t)
	
	if(pointCount < 2):
		return
		
	#rebuild
	var alivedif = (points[pointCount-1].timeAlive - points[0].timeAlive)
	var uvMultiplier = 0
	if(alivedif != 0):
		uvMultiplier = 1/alivedif
	
	pairs = []
	
	var gt = get_global_transform()
	
	for i in range(pointCount):
		var p = points[i]
		var ratio = 1
		if(lifeTime > 0):
			ratio = p.timeAlive / lifeTime
		
		var width = lerp(startWidth,endWidth,ratio)
		
		var uvRatio = (p.timeAlive - points[0].timeAlive)*uvMultiplier
		var c = Color(startColor.to_html()).linear_interpolate(endColor,uvRatio)
		
		var _v = Vector2(0,width/2)
		var t = p.transform
		
		var nt = null
		var a = 0
		
		if(i < pointCount-1):
			nt = points[i+1].transform
			a = nt.get_origin().angle_to_point(t.get_origin())
		else:
			nt = points[i-1].transform
			a = t.get_origin().angle_to_point(nt.get_origin())
		
		t = t.rotated(deg2rad(rad2deg(a)-90))
		
		var v1 = t.xform(_v)
		var v2 = t.xform(-_v)
		
		var uvw = uvRatio
		var uvh = 1
		
		if(texture):
			uvw = uvRatio*texture.get_width()
			if(flipH):
				uvw = (1-uvRatio)*texture.get_width()
			uvh = texture.get_height()
		
		var uv1 = Vector2(uvw,0)
		var uv2 = Vector2(uvw,uvh)
		if(flipV):
			uv2 = Vector2(uvw,0)
			uv1 = Vector2(uvw,uvh)
		
		p.vectors = [v1,v2]
		p.uvs = [uv1,uv2]
		p.color = c
		
		
	
	get_center()
	instance.set_global_transform(Matrix32())
	#pairs.sort_custom(self,"sort")
	updatePairs()
	
	instance.set_polygon(Vector2Array(verts))
	instance.set_uv(Vector2Array(uvs))
	instance.set_vertex_colors(colors)



