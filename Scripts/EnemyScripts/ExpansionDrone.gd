extends CharacterBody2D

var target: Node2D
var destroy_signal: Signal
var expansion_complete: Signal
var add_rebuild: Signal
var to_build: PackedScene
var expansion_idx: int
var expansion_position: int
var is_rebuild: bool

@export var max_hp = 100
@export var current_hp = 0
@export var hp_bar: ProgressBar
@export var speed = 20

func _ready():
	current_hp = max_hp
	hp_bar.value = current_hp
	hp_bar.max_value = max_hp

func _physics_process(delta):
	$Sprite.look_at(target.global_position)
	velocity = Vector2.ZERO
	
	if global_position.distance_to(target.global_position) > 10:
		var move_vector = global_position.direction_to(target.global_position)
		velocity = move_vector.normalized() * speed
		move_and_slide()
	else:
		build_expansion()
		
func build_expansion():
	var expansion =  to_build.instantiate()
	expansion.global_position = target.global_position
	expansion.add_rebuild = add_rebuild
	expansion.rebuild_idx = expansion_idx
	expansion.expansion_position = expansion_position

	if is_rebuild:
		target.queue_free()
		
	get_tree().root.get_node("World/Objects/Units").add_child(expansion)
	expansion_complete.emit(is_rebuild)
	queue_free()
	
func take_dmg(dmg):
	current_hp -= dmg
	hp_bar.value = current_hp
	hp_bar.visible = true
	
	if current_hp < 0:
		destroy_signal.emit()
		queue_free()
