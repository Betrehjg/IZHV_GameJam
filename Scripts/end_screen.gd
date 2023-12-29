extends CanvasLayer

func _ready():
	if Replicator.won:
		$YouWon.visible = true
	else:
		$GameOver.visible = true

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_exit_pressed():
	get_tree().quit()
