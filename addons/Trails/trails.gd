tool
extends EditorPlugin

func get_name(): 
	return "Trails"

func _init():
	print("TRAILS INIT")

func _enter_tree():
	add_custom_type("Trail2D","Node2D",preload("2DTrail.gd"),preload("trails2d.png"))
	add_custom_type("Trail3D","Spatial",preload("3DTrail.gd"),preload("trails3d.png"))
func _exit_tree():
	remove_custom_type("Trail2D")
	remove_custom_type("Trail3D")
