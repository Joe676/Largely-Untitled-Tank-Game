extends Control

func _on_HostButton_pressed():
	get_tree().change_scene("res://UI/HostMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST) # see: https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html

func _on_JoinButton_pressed():
	get_tree().change_scene("res://UI/JoinMenu.tscn")
	
