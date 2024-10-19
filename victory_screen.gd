extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true 
	
	$%Restart.pressed.connect(on_restart_button_pressed)
	$%Quit.pressed.connect(on_quit_button_pressed)
	
func on_restart_button_pressed():
	get_tree().change_screen_to_file("res://scenes/main_menu.tscn")
func on_quit_button_pressed():
	get_tree().quit()
