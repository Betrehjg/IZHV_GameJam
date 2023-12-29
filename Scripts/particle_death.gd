extends CPUParticles2D

func _ready():
	var new_parent = get_node("/root/World/Objects/Particles")
	get_parent().remove_child(self)
	new_parent.add_child(self)
	
	restart()

func _on_finished():
	queue_free()
