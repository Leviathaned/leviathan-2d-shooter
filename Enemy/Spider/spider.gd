extends Area2D

@export var health = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# run this function to make the enemy take damage
func take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()
