extends Area2D

var speed = 3000

func _physics_process(delta):
	position += transform.x * speed * delta
	
#This function deletes the bullet if it hits anything at all.
func _on_Bullet_body_entered(body):
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
