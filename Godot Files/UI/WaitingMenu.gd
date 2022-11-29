extends Control


func _ready():
	yield(get_tree().create_timer(3), "timeout")
	GameState.start_round()
