extends Path2D

@export var inc = 0
@export var speed = 500
@export var decay = 0.96

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	inc += delta * speed
	$PathFollow2D.progress=inc
	
	speed = speed * decay
