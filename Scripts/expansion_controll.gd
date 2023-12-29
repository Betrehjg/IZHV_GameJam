extends Node2D

var rebuild_idx: int
var add_rebuild: Signal
var expansion_position: int
var sent_request = false

func _on_child_exiting_tree(node):
	if not sent_request:
		add_rebuild.emit(rebuild_idx, expansion_position, self)
		sent_request = true
