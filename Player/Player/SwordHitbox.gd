extends Area2D

@export var sword_damage = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	print("entering an area!")
	if area.is_in_group("mobs"):
		area.take_damage(sword_damage)
