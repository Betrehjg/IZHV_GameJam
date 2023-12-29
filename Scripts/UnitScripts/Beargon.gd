extends "res://Scripts/UnitScripts/Unit.gd"

var in_attack = false

@export var wings: AnimatedSprite2D
@export var fire_breath: Node2D
@export var breath_timer: Timer
@export var breath_dmg_cd: float = 0.5

func _physics_process(delta):
	super._physics_process(delta)
	
	if velocity == Vector2.ZERO:
		wings.play("Idle")
	else:
		wings.play("Move")
		
func stop_attack():
	fire_breath.get_node("Area2D").set_deferred("monitoring", false)
	fire_breath.visible = false
	breath_timer.stop()
	in_attack = false
		
func do_attack():
	if not in_attack:
		fire_breath.get_node("Area2D").set_deferred("monitoring", true)
		fire_breath.visible = true
		breath_timer.start(breath_dmg_cd)
		fire_tick()
	
func fire_tick():
	if fire_breath.get_node("Area2D").monitoring == true:
		var targets = fire_breath.get_node("Area2D").get_overlapping_bodies()

		for target in targets:
			target.take_dmg(dmg)

func _on_breath_timer_timeout():
	fire_tick()
	breath_timer.start(breath_dmg_cd)
