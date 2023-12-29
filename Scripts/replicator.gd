extends Node

var won = false
var mutate_chance = 30

func get_my_scene(my_type):
	var will_mutate = RandomNumberGenerator.new().randf_range(0, 100)
	if will_mutate > mutate_chance:
		return get_unit_scene(my_type)
	else:
		var mutate_type = RandomNumberGenerator.new().randf_range(0, 100)
		match my_type:
			"Bear":
				if mutate_type < 60:
					return get_unit_scene("Bearicopter")
				elif mutate_type < 90:
					return get_unit_scene("Beargant")
				else:
					return get_unit_scene("Beargon")
			"Bearicopter":
				if mutate_type < 45:
					return get_unit_scene("Beargon")
				elif mutate_type < 70:
					return get_unit_scene("Beargant")
				else:
					return get_unit_scene("Bearicopter")
			"Beargant":
				if mutate_type < 30:
					return get_unit_scene("Bearicopter")
				elif mutate_type < 60:
					return get_unit_scene("Beargon")
				else:
					return get_unit_scene("Beargant")
			"Beargon":
				if mutate_type < 10:
					return get_unit_scene("Bearicopter")
				elif mutate_type < 20:
					return get_unit_scene("Beargant")
				else:
					return get_unit_scene("Beargon")
	
func get_unit_scene(unit_name: String):
	match unit_name:
		"Bear":
			return preload("res://Objects/Units/bear.tscn")
		"Bearicopter":
			return preload("res://Objects/Units/bearicopter.tscn")
		"Beargant":
			return preload("res://Objects/Units/beargant.tscn")
		"Beargon":
			return preload("res://Objects/Units/Beargon.tscn")
		_:
			print(unit_name)
	
func check_game_end():
	var unit_count = get_tree().root.get_node("World/Objects/Units").get_child_count()
	
	if unit_count <= 1:
		won = false
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
