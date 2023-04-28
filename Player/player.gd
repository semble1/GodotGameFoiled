extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DECELERATION = 2000.0
const SLIDE_DECELERATION = 4000.0
const SLIDE_SPEED_MULTIPLIER = 2.5

@export var max_health: int = 100
var current_health: int = max_health

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var animation_player = get_node("AnimationPlayer")
@onready var hurtbox = $AnimatedSprite2D/hurtbox
@onready var hitbox = $AnimatedSprite2D/hitbox

var state = "Idle"
var is_hurt = false
var last_direction = 0
var attack_state = "NotAttacking"
var can_chain_attack = false

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if not is_on_floor():
		velocity.y += gravity * delta
		if state != "Attack" and state != "JumpAttack":
			if is_on_wall() and velocity.y > 0:
				velocity.y = velocity.y/1.5
				state = "WallSlide"
			else:
				state = "Jump"
	elif direction != 0 and state != "Attack":
		if Input.is_action_pressed("ui_down"):
			state = "Slide"
		else:
			state = "Run"
	elif state != "Attack":
		state = "Idle"

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_attack"):
		if state == "Jump":
			state = "JumpAttack"
		elif state != "Attack" and state != "JumpAttack":
			state = "Attack"
			velocity.x = 0
			if can_chain_attack:
				if attack_state == "Attack1":
					attack_state = "Attack2"
				elif attack_state == "Attack2":
					attack_state = "Attack3"
				else:
					attack_state = "Attack1"
			else:
				attack_state = "Attack1"
	
	if state != "Attack" and state != "JumpAttack":
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
	if is_hurt:
		state = "Hurt"
	match state:
		"Idle":
			if animation_player.current_animation != "Idle":
				animation_player.play("Idle")
		"Hurt":
			if animation_player.current_animation != "Hurt":
				animation_player.play("Hurt")
		"Run":
			if animation_player.current_animation != "Run":
				animation_player.play("Run")
		"Jump":
			if animation_player.current_animation != "Jump":
				animation_player.play("Jump")
		"Attack":
			match attack_state:
				"Attack1":
					if animation_player.current_animation != "Attack1":
						animation_player.play("Attack1")
				"Attack2":
					if animation_player.current_animation != "Attack2":
						animation_player.play("Attack2")
				"Attack3":
					if animation_player.current_animation != "Attack3":
						animation_player.play("Attack3")
		"JumpAttack":
			if animation_player.current_animation != "JumpAttack":
				animation_player.play("JumpAttack")
		"Slide":
			if animation_player.current_animation != "Slide":
				animation_player.play("Slide")
		"WallSlide":
			if animation_player.current_animation != "WallSlide":
				animation_player.play("WallSlide")
	if velocity.x > 0:
		animated_sprite.scale.x = 1
		animated_sprite.offset.x = 0
		hitbox.position.x = 0
		hurtbox.position.x = 0
	elif velocity.x < 0:
		animated_sprite.scale.x = -1
		animated_sprite.offset.x = 23
		hitbox.position.x = 23
		hurtbox.position.x = 23

func take_damage(damage: int):
	current_health -= damage
	current_health = clamp(current_health, 0, max_health)
	if current_health > 0:
		is_hurt = true
	elif current_health <= 0:
		die()

func die():
	print("Character died")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Hurt":
		is_hurt = false
	elif anim_name == "Attack1" or anim_name == "Attack2":
		$AttackWaitTimer.start()
		state = "Idle"
	elif anim_name == "Attack3":
		can_chain_attack = false
		state = "Idle"
	elif anim_name == "JumpAttack":
		can_chain_attack = false
		state = "Idle"

func _on_attack_chain_timer_timeout():
	can_chain_attack = false

func _on_attack_wait_timer_timeout():
	can_chain_attack = true
	$AttackChainTimer.start()

func _on_hurtbox_character_hit(damage):
	print(damage)
	take_damage(damage)
