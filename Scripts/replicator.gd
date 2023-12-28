extends Node

func get_my_scene(my_type):
	match my_type:
		"Bear":
			return preload("res://Objects/bear.tscn")
		"Bearicopter":
			pass		

func mutate():
	pass
