extends Node

onready var health_over = $HealthOver
onready var health_under = $HealthUnder
onready var health_tween = $HealthTween

onready var shots_label = $ShotsLabel

func _on_health_updated(health, amount):
	health_over.value = health
	health_tween.interpolate_property(health_under, "value", health_under.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	health_tween.start()

func _on_health_given(health, amount):
	health_over.value = health
	health_under.value = health

func _set_pistol_shots(shotnum):
	shots_label.text = str(shotnum)
