extends CanvasLayer
 
var current_page = 0

@export var page1: RichTextLabel
@export var page2: RichTextLabel

@export var next_btn: Button
@export var prev_btm: Button
@export var pause_menu: CanvasLayer

func _ready():
	get_tree().paused = true
	process_mode

func _on_previous_pressed():
	next_btn.visible = true
	prev_btm.visible = false
	page1.visible = true
	page2.visible = false

func _on_start_pressed():
	get_tree().paused = false
	visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_pressed():
	next_btn.visible = false
	prev_btm.visible = true
	page1.visible = false
	page2.visible = true
