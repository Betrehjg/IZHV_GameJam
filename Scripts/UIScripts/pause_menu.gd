extends CanvasLayer

func _input(event):
	if event.is_action_pressed("TogleMenu"):
		visible = !visible
		get_tree().paused = !get_tree().paused

func _on_exit_pressed():
	get_tree().quit()

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_continue_pressed():
	get_tree().paused = false
	visible = false
