extends Control

onready var health_bar = $HealthBar

func _ready():
	health_bar.min_value = 0

func _on_health_updated(new_amount, max_health):
	health_bar.max_value = max_health
	health_bar.value = new_amount