extends StaticBody2D

var current_hp = 100

@export var hp_bar: ProgressBar
@export var max_hp: float

# Called when the node enters the scene tree for the first time.
func _ready():
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func take_dmg(dmg):
	current_hp -= dmg
	hp_bar.value = current_hp
	hp_bar.visible = true
	
	if current_hp <= 0:
		queue_free()
