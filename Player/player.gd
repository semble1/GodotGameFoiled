extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DECELERATION = 2000.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = get_node("AnimatedSprite2D")
var state = "Idle"
var last_direction = 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		state = "Jump"
	elif Input.get_axis("ui_left", "ui_right") != 0:
		state = "Run"
	else:
		state = "Idle"

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	up_direction = Vector2.UP
	move_and_slide()
	update_animation()

func update_animation():
	match state:
		"Idle":
			if animated_sprite.animation != "Idle":
				animated_sprite.play("Idle")
		"Run":
			if animated_sprite.animation != "Run":
				animated_sprite.play("Run")
		"Jump":
			if animated_sprite.animation != "Jump":
				animated_sprite.play("Jump")
	if velocity.x > 0:
		animated_sprite.flip_h = false
		animated_sprite.offset.x = 0
	elif velocity.x < 0:
		animated_sprite.flip_h = true
		animated_sprite.offset.x = -25
