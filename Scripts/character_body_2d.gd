extends CharacterBody2D

const SPEED = 75.0
const SPRINT_SPEED = 275.0
const JUMP_VELOCITY = -300.0

# References to all 6 synchronized sprite layers
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var animated_sprite_3: AnimatedSprite2D = $AnimatedSprite2D3
@onready var animated_sprite_4: AnimatedSprite2D = $AnimatedSprite2D4
@onready var animated_sprite_5: AnimatedSprite2D = $AnimatedSprite2D5
@onready var animated_sprite_6: AnimatedSprite2D = $AnimatedSprite2D6

# State tracking flags
var is_attacking: bool = false
var is_dead: bool = false

func _physics_process(delta: float) -> void:
	# IF PLAYER IS DEAD: Exit early. Stop all movements, inputs, and animations.
	if is_dead:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Determine if the player is walking or sprinting
	var current_speed = SPEED
	if Input.is_action_pressed("ui_sprint"):
		current_speed = SPRINT_SPEED

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	# TEST TRIGGER: Press your custom 'suicide' input key to die
	if Input.is_action_just_pressed("suicide"):
		kill_player()
		return # Exit immediately so movement blocks don't process this frame

	# 1. FLIP SPRITE DIRECTION
	# Turn all 6 sprite layers to face the direction you are walking
	if direction > 0:
		animated_sprite.flip_h = true
		animated_sprite_2.flip_h = true
		animated_sprite_3.flip_h = true
		animated_sprite_4.flip_h = true
		animated_sprite_5.flip_h = true
		animated_sprite_6.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
		animated_sprite_2.flip_h = false
		animated_sprite_3.flip_h = false
		animated_sprite_4.flip_h = false
		animated_sprite_5.flip_h = false
		animated_sprite_6.flip_h = false

	# 2. CHOOSE ANIMATION STATE
	# Check for attack input first
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")
		animated_sprite_2.play("attack")
		animated_sprite_3.play("attack")
		animated_sprite_4.play("attack")
		animated_sprite_5.play("attack")
		animated_sprite_6.play("attack")
		
	# ONLY play movement animations if we are NOT currently attacking
	if not is_attacking:
		if not is_on_floor():
			if velocity.y < 0:
				animated_sprite.play("jump_up")
				animated_sprite_2.play("jump_up")
				animated_sprite_3.play("jump_up")
				animated_sprite_4.play("jump_up")
				animated_sprite_5.play("jump_up")
				animated_sprite_6.play("jump_up")
			else:
				animated_sprite.play("jump_down")
				animated_sprite_2.play("jump_down")
				animated_sprite_3.play("jump_down")
				animated_sprite_4.play("jump_down")
				animated_sprite_5.play("jump_down")
				animated_sprite_6.play("jump_down")
		elif velocity.x == 0:
			animated_sprite.play("idle")
			animated_sprite_2.play("idle")
			animated_sprite_3.play("idle")
			animated_sprite_4.play("idle")
			animated_sprite_5.play("idle")
			animated_sprite_6.play("idle")
		elif Input.is_action_pressed("ui_sprint") and direction != 0:
			animated_sprite.play("run")
			animated_sprite_2.play("run")
			animated_sprite_3.play("run")
			animated_sprite_4.play("run")
			animated_sprite_5.play("run")
			animated_sprite_6.play("run")
		else:
			animated_sprite.play("walk")
			animated_sprite_2.play("walk")
			animated_sprite_3.play("walk")
			animated_sprite_4.play("walk")
			animated_sprite_5.play("walk")
			animated_sprite_6.play("walk")

	move_and_slide()

# Custom function to trigger character death sequence
func kill_player() -> void:
	if not is_dead:
		is_dead = true
		velocity = Vector2.ZERO # Stop physical movement completely
		
		# Play the death animation simultaneously on all layers
		animated_sprite.play("die")
		animated_sprite_2.play("die")
		animated_sprite_3.play("die")
		animated_sprite_4.play("die")
		animated_sprite_5.play("die")
		animated_sprite_6.play("die")

# Resets attack status back to false once the animation wraps up
# Make sure your main $AnimatedSprite2D has its 'animation_finished' signal connected here!
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
