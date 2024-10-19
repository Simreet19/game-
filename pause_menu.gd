extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _unhandle_key_input(event):
	if event.is_action_released("ui_selected"):
		get_tree().paused = true
		$paused/ui.show()
		

	

func _on_continue_pressed():
	get_tree().paused = false
	$paused/ui.hide()
	



func _on_restart_pressed():
	get_tree().reload_current_scene()
	$paused/ui.hide()
	



func _on_exit_pressed():
	# Change to the main menu scene
	get_tree().change_scene("res://scenes/control.tscn")
