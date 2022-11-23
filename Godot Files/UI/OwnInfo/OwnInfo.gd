extends Control

onready var health_bar = $HealthBar
onready var bullets_lbl = $VFlowContainer/AmmoAmount

func _ready():
	health_bar.min_value = 0

func _on_health_updated(new_amount, max_health):
	health_bar.max_value = max_health
	health_bar.value = new_amount

func _on_bullets_updated(current_bullets, max_bullets):
	bullets_lbl.text = "%d / %d" % [current_bullets, max_bullets]