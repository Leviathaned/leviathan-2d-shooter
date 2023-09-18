extends Area2D

@export var damage = 0

var prepare_damage = false
var mob = null

var speed = 3000

func _physics_process(delta):
	position += transform.x * speed * delta

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if prepare_damage:
		mob.take_damage(damage)
		queue_free()
	

func _on_area_entered(area):
	if area.is_in_group("mobs"):
		mob = area
		prepare_damage = true
	
	if area.is_in_group("bullet shield"):
		queue_free()
		
	
