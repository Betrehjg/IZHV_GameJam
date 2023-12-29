extends StaticBody2D

var current_hp
var current_expansion = 0
var max_expansion
var rebuild_queu: Array[Dictionary]

@export var max_hp = 1000
@export var hp_bar: ProgressBar
@export var expansion_timer: Timer
@export var expansion_cd: float
@export var expansion_drone: PackedScene
@export var expansion_presets: Array[PackedScene]

signal ship_destoryed
signal expansion_complete(is_rebuild: bool)
signal rebuild(expansion_idx: int, expansion_pos: int, request_node: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	expansion_timer.start(expansion_cd)
	max_expansion = get_tree().root.get_node("World/Objects/Expansions").get_child_count()

func take_dmg(dmg):
	current_hp -= dmg
	hp_bar.value = current_hp
	hp_bar.visible = true
	
	if current_hp <= 0:
		Replicator.won = true
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
		
func send_expansion_drone(is_rebuild:bool, rebuild_info = null):
	var drone = expansion_drone.instantiate()
	if is_rebuild:
		drone.target = rebuild_info["node"]
		drone.expansion_position = rebuild_info["position"]
		drone.to_build = expansion_presets[rebuild_info["idx"]]
		drone.expansion_idx = rebuild_info["idx"]
	else:
		drone.target = get_tree().root.get_node("World/Objects/Expansions/Expansion" + str(current_expansion))
		var expansion_idx = RandomNumberGenerator.new().randi_range(0, len(expansion_presets) - 1)
		drone.to_build = expansion_presets[expansion_idx]
		drone.expansion_idx = expansion_idx
		drone.expansion_position = current_expansion
		
	drone.destroy_signal = ship_destoryed
	drone.expansion_complete = expansion_complete
	drone.global_position = global_position
	drone.add_rebuild = rebuild
	drone.expansion_position = current_expansion
	drone.is_rebuild = is_rebuild
	
	get_tree().root.get_node("World/Objects/Drones").add_child(drone)

func _on_timer_timeout():
	if not rebuild_queu.is_empty():
		send_expansion_drone(true, rebuild_queu[0])
	elif current_expansion < max_expansion:
		send_expansion_drone(false)
	
func _on_expansion_complete(is_rebuild: bool):
	if is_rebuild:
		rebuild_queu.pop_front()
	else:
		current_expansion += 1
		
	expansion_timer.start(expansion_cd)

func _on_ship_destoryed():
	expansion_timer.start(expansion_cd)

func _on_rebuild(expansion_idx: int, expansion_pos:int, request_node: Node2D):
	var rebuild_req:Dictionary
	rebuild_req["position"] = expansion_pos
	rebuild_req["idx"] = expansion_idx
	rebuild_req["node"] = request_node
	rebuild_queu.push_back(rebuild_req)
