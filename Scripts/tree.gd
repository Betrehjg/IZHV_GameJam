extends Area2D

var current_honey: int

@export var max_honey: int = 100
@export var animation_player: AnimationPlayer
@export var add_honey_timer: Timer
@export var amount_added: int = 50
@export var time_betweed_new_honey: float = 4
@export var fruit_sprite: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	current_honey = max_honey
	fruit_sprite.frame = 10
	
func change_fruit_sprite():
	var sprite_idx = int((float(current_honey) / max_honey) * 100) / 10
	fruit_sprite.frame = sprite_idx

func eat_honey(amout_request: float) -> float:
	var returned_honey = 0
	if current_honey - amout_request < 0:
		returned_honey =  current_honey
	else:
		returned_honey = amout_request
		
	current_honey = max(0, current_honey - amout_request)
		
	if not animation_player.is_playing():
		animation_player.play("shake")
		
	add_honey_timer.start(time_betweed_new_honey)
	change_fruit_sprite()
	return returned_honey

func _on_add_honey_timeout():
	current_honey = min(current_honey + amount_added, max_honey)
	
	if current_honey < max_honey:
		add_honey_timer.start(time_betweed_new_honey)
	
	change_fruit_sprite()
