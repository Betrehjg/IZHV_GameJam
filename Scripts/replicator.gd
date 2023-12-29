extends Node

var won = false

func get_my_scene(my_type):
	match my_type:
		"Bear":
			return preload("res://Objects/bear.tscn")
		"Bearicopter":
			pass		

func mutate():
	pass
	
func check_game_end():
	var unit_count = get_tree().root.get_node("World/Objects/Units").get_child_count()
	
	if unit_count <= 1:
		won = false
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
