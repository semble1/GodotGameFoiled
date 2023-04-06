extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DECELERATION = 2000.0
const SLIDE_DECELERATION = 4000.0
const SLIDE_SPEED_MULTIPLIER = 2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = get_node("AnimatedSprite2D")
var state = "Idle"
var last_direction = 0
var attack_state = "NotAttacking"
var can_chain_attack = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if state != "Attack" and state != "JumpAttack":
			state = "Jump"
	elif Input.get_axis("ui_left", "ui_right") != 0 and state != "Attack":
		if Input.is_action_pressed("ui_down"):
			state = "Slide"
		else:
			state = "Run"
	elif state != "Attack":
		state = "Idle"

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_attack"):
		if state == "Jump":
			state = "JumpAttack"
		elif state != "Attack" and state != "JumpAttack":
			state = "Attack"
			attack_state = "Attack1"
			velocity.x = 0
			if can_chain_attack:
				if attack_state == "Attack1":
					attack_state = "Attack2"
				else:
					attack_state = "Attack1"
	
	if state != "Attack" and state != "JumpAttack":
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			if state == "Slide":
				velocity.x = direction * SPEED * SLIDE_SPEED_MULTIPLIER
			else:
				velocity.x = direction * SPEED
			last_direction = direction
		else:
			if state == "Slide":
				velocity.x = move_toward(velocity.x, 0, SLIDE_DECELERATION * delta)
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
		"Attack":
			match attack_state:
				"Attack1":
					if animated_sprite.animation != "Attack1":
						animated_sprite.play("Attack1")
				"Attack2":
					if animated_sprite.animation != "Attack2":
						animated_sprite.play("Attack2")
		"JumpAttack":
			if animated_sprite.animation != "JumpAttack":
				animated_sprite.play("JumpAttack")
		"Slide":
			if animated_sprite.animation != "Slide":
				animated_sprite.play("Slide")
	if velocity.x > 0:
		animated_sprite.flip_h = false
		animated_sprite.offset.x = 0
	elif velocity.x < 0:
		animated_sprite.flip_h = true
		animated_sprite.offset.x = -25
		
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Attack1":
		can_chain_attack = true
		$AttackChainTimer.start()
		state = "Idle"
	elif animated_sprite.animation == "Attack2":
		can_chain_attack = false
		state = "Idle"
	elif animated_sprite.animation == "JumpAttack" or animated_sprite.animation == "Slide":
		state = "Idle"

func _on_attack_chain_timer_timeout():
	can_chain_attack = false
