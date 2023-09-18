extends Area2D

signal health_depleted
@export var health = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage(damage):
	print("Enemy took " + str(damage) + " damage!")
	health -= damage
	if health <= 0:
		health_depleted.emit()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
