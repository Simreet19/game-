extends CharacterBody2D

# Player parameters
var speed: float = 200.0
var jump_force: float = 400.0
var gravity: float = 800.0

# Animation variables
@onready var animated_sprite = $AnimatedSprite2D

# States
enum PlayerState {
	IDLE,
	ATTACK,
	DEATH,
	SKILL,
	SUMMON,
}

var current_state: PlayerState = PlayerState.IDLE

func _ready():
	animated_sprite.play("idle")

func _process(delta: float) -> void:
	handle_input(delta)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func handle_input(delta: float) -> void:
	var input_direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1

	if input_direction.x != 0:
		if current_state != PlayerState.ATTACK and current_state != PlayerState.DEATH:
			current_state = PlayerState.IDLE
			animated_sprite.play("idle")
		
		# Move the player
		velocity.x = input_direction.x * speed
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	if Input.is_action_just_pressed("attack"):
		perform_attack()

	if Input.is_action_just_pressed("skill"):
		perform_skill()

	if Input.is_action_just_pressed("summon"):
		perform_summon()

func perform_attack() -> void:
	if current_state != PlayerState.DEATH:
		current_state = PlayerState.ATTACK
		animated_sprite.play("attack")

func perform_skill() -> void:
	if current_state != PlayerState.DEATH:
		current_state = PlayerState.SKILL
		animated_sprite.play("skill")

func perform_summon() -> void:
	if current_state != PlayerState.DEATH:
		current_state = PlayerState.SUMMON
		animated_sprite.play("summon")

func die() -> void:
	current_state = PlayerState.DEATH
	animated_sprite.play("death")

# Call this function to reset the player's state to idle
func reset_state() -> void:
	if current_state == PlayerState.DEATH:
		return
	current_state = PlayerState.IDLE
	animated_sprite.play("idle")
	
