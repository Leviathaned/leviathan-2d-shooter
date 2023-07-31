extends Area2D
signal hit

@export var speed = 200
@export var fire_rate = 0.2
@export var bullet_damage = 2
@export var shot : PackedScene

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#facing the bullet
	look_at(get_global_mouse_position())
	
	#handles player movement
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	#when player fires bullets
	if Input.is_action_pressed("shoot") and $FireRateTimer.is_stopped():
		shoot()

func _on_body_entered(body):
	hide()
	hit.emit()
	#must be deferred as we can't change physics properties on a physics callback
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

#the shoot function, called when the player hits the shoot button in gun mode:
func shoot():
		var b = shot.instantiate()
		get_tree().root.add_child(b)
		b.damage = bullet_damage
		b.transform = $Marker2D.global_transform
		$FireRateTimer.start(fire_rate)
