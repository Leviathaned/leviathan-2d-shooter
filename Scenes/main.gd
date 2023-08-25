extends Node2D

var game_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("pause"):
		if game_paused == false:
			print("The game is being paused!")
			get_tree().paused = true
			game_paused = true
		else:
			print("The game is being unpaused!")
			get_tree().paused = false
			game_paused = false
