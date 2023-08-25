extends Area2D
signal hit

@export var speed = 200
@export var fire_rate = 0.2
@export var bullet_damage = 2
@export var shot : PackedScene

var screen_size
# stance represents gun stance or sword stance. 0 is gun stance, 1 is sword stance.
var stance = 0
# this variable represents whether the player can currently take an action (swinging, shooting)
var actionable = true

var state = "idle"
var queued_action = "idle"

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
	
	#switching between stances
	if Input.is_action_just_pressed("switch_stance"):
		switch_stance()
		
	#all gun stance actions
	if stance == 0:
		#when player fires bullets
		if Input.is_action_pressed("shoot") and $FireRateTimer.is_stopped():
			shoot()
			
	#all sword stance actions
	if stance == 1:
		if Input.is_action_just_pressed("slash"):
			slash()

func _on_body_entered(body):
	hide()
	hit.emit()
	#must be deferred as we can't change physics properties on a physics callback
	$Hurtbox.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$Hurtbox.disabled = false

func switch_stance():
	if stance == 0:
		stance = 1
	else:
		stance = 0

#the shoot function, called when the player hits the shoot button in gun mode:
func shoot():
	var b = shot.instantiate()
	get_tree().root.add_child(b)
	b.damage = bullet_damage
	b.transform = $Marker2D.global_transform
	$FireRateTimer.start(fire_rate)
		
func slash():
	if actionable == true:
		$Sword/SwingLTRHitbox.disabled = false
		$AnimatedSprite2D.play("swing_ltr")
	else:
		queued_action = "slash"
	actionable = false
	
func disable_swordboxes():
	$Sword/SwingLTRHitbox.disabled = true
	$Sword/SwingRTLHitbox.disabled = true
		

func player_animation_finished():
	disable_swordboxes()
	if stance == 1:
		if queued_action == "idle":
			$AnimatedSprite2D.play("idle sword")
			actionable = true
		if queued_action == "slash":
			if $AnimatedSprite2D.animation == "swing_ltr":
				$AnimatedSprite2D.play("swing_rtl")
				$Sword/SwingRTLHitbox.disabled = false
			else:
				$AnimatedSprite2D.play("swing_ltr")
				$Sword/SwingLTRHitbox.disabled = false
			queued_action = "idle"

