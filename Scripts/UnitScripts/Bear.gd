extends "res://Scripts/UnitScripts/Unit.gd"

@export var hit_area: Area2D
	
func _on_sprite_frame_changed():
	if anim_sprite.frame == 4 and anim_sprite.animation == "Attack":
		var hits = hit_area.get_overlapping_bodies()
		
		for hit in hits:
			hit.take_dmg(dmg)
