extends "res://Scripts/UnitScripts/Unit.gd"

@export var hit_area: Area2D
@export var bonk_timer: Timer

func _ready():
	super._ready()
	hit_area.monitoring = false

func _on_hit_area_body_entered(body):
	body.take_dmg(dmg)

func _on_bonk_timer_timeout():
	hit_area.monitoring = false
	
func _on_sprite_frame_changed():
	if anim_sprite.frame == 4 and anim_sprite.animation == "Attack":
		hit_area.monitoring = true
		bonk_timer.start(0.1)
