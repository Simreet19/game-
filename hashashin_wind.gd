extends CharacterBody2D

# Movement variables
@export var speed: float = 130.0
@export var jump_force: float = -300.0
@export var gravity: float = 20.0
var _velocity: Vector2 = Vector2.ZERO
var is_jumping: bool = false

# Player health
@export var max_health: int = 100
var current_health: int

# Player state
enum State {IDLE, RUN, JUMP, ATTACK, DEFEND, ROLL, SPECIAL_ATTACK, HIT, DEATH}
var current_state: State = State.IDLE

# Animation reference
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Particle reference (for special attack)
@onready var special_attack_particles: CPUParticles2D = $CPUParticles2D

# Damage values for attacks
var attack_damage: Dictionary = {
	"1": 1,
	"2": 4,
	"3": 7,
	"special": 15
}

# Variable to prevent other animations from playing while one is active
var is_animation_locked: bool = false

func _ready():
	# Set initial state and health
	current_state = State.IDLE
	animated_sprite.play("idle")
	current_health = max_health
	
	# Connect the animation_finished signal to handle when animations complete
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# Ensure the particles are disabled at the start
	$AnimatedSprite2D/CPUParticles2D.emitting = false

func _physics_process(delta: float) -> void:
	handle_input()

	# Apply gravity when the player is in the air
	if not is_on_floor():
		velocity.y += gravity

	# Move the player
	move_and_slide()
	update_animation()

	# Check if the player is dead
	if current_health <= 0:
		handle_death()

func handle_input() -> void:
	# Do nothing if an animation is locked (i.e., another animation is playing)
	if is_animation_locked:
		return
	
	var input_direction: Vector2 = Vector2.ZERO
	
	# Handle left-right movement
	if Input.is_physical_key_pressed(KEY_RIGHT):
		input_direction.x += 1
		$AnimatedSprite2D.flip_h = false  # Face right
	elif Input.is_physical_key_pressed(KEY_LEFT):
		input_direction.x -= 1
		$AnimatedSprite2D.flip_h = true  # Face left

	# Set velocity and state for movement
	if input_direction.x != 0:
		velocity.x = input_direction.x * speed
		if not is_jumping:
			current_state = State.RUN
	else:
		velocity.x = 0
		if not is_jumping and current_state != State.ATTACK:
			current_state = State.IDLE

	# Jump
	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
		current_state = State.JUMP

	# Attacks (1, 2, 3)
	if Input.is_physical_key_pressed(KEY_1):
		current_state = State.ATTACK
		play_animation("1_atk")
	elif Input.is_physical_key_pressed(KEY_2):
		current_state = State.ATTACK
		play_animation("2_atk")
	elif Input.is_physical_key_pressed(KEY_3):
		current_state = State.ATTACK
		play_animation("3_atk")

	# Air attack
	if not is_on_floor() and Input.is_physical_key_pressed(KEY_J):
		play_animation("air_atk")
		# Example damage handling for air attack can be added here

	# Defend
	if Input.is_physical_key_pressed(KEY_D):
		current_state = State.DEFEND
		play_animation("defend")

	# Special attack
	if Input.is_physical_key_pressed(KEY_F):
		current_state = State.SPECIAL_ATTACK
		play_animation("sp_atk")
		activate_special_attack_particles()

	# Roll
	if Input.is_action_just_pressed("roll"):
		current_state = State.ROLL
		play_animation("roll")

	# Taking hit
	if Input.is_action_just_pressed("take_hit"):
		current_state = State.HIT
		play_animation("take_hit")

	# Death
	if Input.is_action_just_pressed("death"):
		current_state = State.DEATH
		play_animation("death")

	# Reset jump when landing
	if is_on_floor():
		is_jumping = false

func play_animation(animation_name: String) -> void:
	# Play the animation and lock input until it finishes
	is_animation_locked = true
	animated_sprite.play(animation_name)

func _on_animation_finished() -> void:
	# Unlock animation so the next one can play
	is_animation_locked = false

	# Deactivate special attack particles when the animation is done
	if current_state == State.SPECIAL_ATTACK:
		deactivate_special_attack_particles()

	# Set the current state back to idle after finishing an animation
	if current_state != State.DEATH:  # Death state should stay as death
		current_state = State.IDLE

func update_animation() -> void:
	match current_state:
		State.IDLE:
			if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		State.RUN:
			if not animated_sprite.is_playing() or animated_sprite.animation != "run":
				animated_sprite.play("run")
		State.JUMP:
			if not animated_sprite.is_playing() or animated_sprite.animation != "jump":
				animated_sprite.play("jump")
		State.ATTACK:
			if not animated_sprite.is_playing():
				animated_sprite.play("idle")  # Reset to idle after attack
		State.DEFEND:
			if not animated_sprite.is_playing() or animated_sprite.animation != "defend":
				animated_sprite.play("defend")
		State.ROLL:
			if not animated_sprite.is_playing() or animated_sprite.animation != "roll":
				animated_sprite.play("roll")
		State.SPECIAL_ATTACK:
			if not animated_sprite.is_playing() or animated_sprite.animation != "sp_atk":
				animated_sprite.play("sp_atk")
		State.HIT:
			if not animated_sprite.is_playing() or animated_sprite.animation != "take_hit":
				animated_sprite.play("take_hit")
		State.DEATH:
			if not animated_sprite.is_playing() or animated_sprite.animation != "death":
				animated_sprite.play("death")

func activate_special_attack_particles() -> void:
	# Activate the particle system
	$AnimatedSprite2D/CPUParticles2D.emitting = true

func deactivate_special_attack_particles() -> void:
	# Deactivate the particle system
	$AnimatedSprite2D/CPUParticles2D.emitting = false

func handle_death() -> void:
	if current_state != State.DEATH:
		current_state = State.DEATH
		animated_sprite.play("death")
		velocity = Vector2.ZERO  # Stop the player from moving
		# Additional logic for when the player dies (e.g., game over screen)
