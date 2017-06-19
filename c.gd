extends Node

func _ready():
	set_process(true)

var time = 0
func _process(delta):
	time += delta
	if time > 10.3:
		self.free()
