extends Area2D

@export var sword_damage = 5

var prepare_damage = false
var current_mobs = []

signal deflected


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if prepare_damage:
		for mob in current_mobs:
			mob.take_damage(sword_damage)
			current_mobs = []
	
	sword_damage = 5

func _on_area_entered(area):
	if area.is_in_group("sword shield"):
		sword_damage = 0
		deflected.emit()
		
	elif area.is_in_group("mobs"):
		prepare_damage = true
		current_mobs.append(area)
		
	


