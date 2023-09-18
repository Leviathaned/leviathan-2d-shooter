extends Area2D
signal hit

@export var speed = 300
@export var fire_rate = 0.2
@export var bullet_damage = 2
@export var shot : PackedScene
@export var sword_swing_push = 200
@export var dash_speed = 500
@export var dash_swing_speed = 350
@export var dash_recovery_speed = 100

var screen_size
# stance represents gun stance or sword stance. 0 is gun stance, 1 is sword stance.
var stance = 0
# this variable represents whether the player can currently take an action (swinging, shooting)
var actionable = true

var dash_direction

var state = "idle"
var queued_action = "idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#facing the bullet
	#handles player movement
	if actionable == true:
		var velocity = Vector2.ZERO
		var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input_direction * speed
			
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			
		position += velocity * delta
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
	
		#switching between stances
		if Input.is_action_just_pressed("switch_stance"):
			switch_stance()
			
		#dash action
		if Input.is_action_just_pressed("dash"):
			dash_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			if dash_direction:
				$AnimatedSprite2D.play("dash")
				actionable = false
				state = "dash"
		
		#all gun stance actions
		if stance == 0:
			#when player fires bullets
			look_at(get_global_mouse_position())
			if Input.is_action_pressed("shoot") and $FireRateTimer.is_stopped():
				shoot()
				
		#all sword stance actions
		if stance == 1:
			if velocity != Vector2.ZERO:
				rotation = atan2(velocity.y, velocity.x)
				
	if state == "dash" or state == "dash swing":
		var mod_dash_speed = dash_speed
		if state == "dash swing":
			mod_dash_speed = dash_swing_speed
		
		var dash_velocity = Vector2.ZERO
		dash_velocity = dash_direction * mod_dash_speed
		
		
		
		position += dash_velocity * delta
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
		
	if state == "dash_recovery":
		var dash_velocity = Vector2.ZERO
		dash_velocity = dash_direction * dash_recovery_speed
	
		position += dash_velocity * delta
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)

	#queueing sword actions
	if stance == 1 and Input.is_action_just_pressed("slash"):
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
		slash_action(0)
	else:
		queued_action = "slash"
	actionable = false
	
	## The slash action handles the actual slash. slash_direction is set to 0 for left to right, and 1 for right to left
func slash_action(slash_direction):
	if slash_direction == 0:
		$AnimatedSprite2D.play("swing_ltr")
		$Sword/SwingLTRHitbox.disabled = false
		
	if slash_direction == 1:
		$AnimatedSprite2D.play("swing_rtl")
		$Sword/SwingRTLHitbox.disabled = false
		
	look_at(get_global_mouse_position())
	var sword_velocity = transform.x * sword_swing_push
	
	position += sword_velocity

func disable_swordboxes():
	$Sword/SwingLTRHitbox.disabled = true
	$Sword/SwingRTLHitbox.disabled = true
		

func player_animation_finished():
	disable_swordboxes()
	#TODO: swap these out for gun sprites
	if state == "dash":
		if queued_action == "slash":
			look_at(get_global_mouse_position())
			$AnimatedSprite2D.play("dash swing")
			state = "dash swing"
			queued_action = "idle"
		else:
			$AnimatedSprite2D.play("dash recovery")
			state = "dash_recovery"
			queued_action = "idle"
			
	elif state == "dash swing":
		$AnimatedSprite2D.play("dash recovery")
		state = "dash_recovery"
		queued_action = "idle"
		
	elif state == "dash_recovery":
		print("recovery finished!")
		$AnimatedSprite2D.play("idle sword")
		state = "idle"
		queued_action = "idle"
		actionable = true
	
	elif stance == 0:
		if queued_action == "idle":
			$AnimatedSprite2D.play("idle sword")
			actionable = true
			state = "idle"
	
	elif stance == 1:
		if queued_action == "idle":
			$AnimatedSprite2D.play("idle sword")
			actionable = true
			state = "idle"
		if queued_action == "slash":
			if $AnimatedSprite2D.animation == "swing_ltr":
				slash_action(1)
			else:
				slash_action(0)
			queued_action = "idle"

#signals
func _on_sword_deflected():
	print("sword clank!")
	
	var sword_velocity = transform.x * -sword_swing_push
	
	position += sword_velocity
	
	$AnimatedSprite2D.play("sword clank")
	state = "sword deflected"
	queued_action = "idle"
	
