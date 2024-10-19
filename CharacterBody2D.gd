extends CharacterBody2D

# Animation states
enum State { IDLE, WALK, ATTACK, TAKE_HIT, DEATH }

# Boss variables
var state = State.IDLE
var health = 100
var speed = 100
var target = null
var attack_timer = 0.0
var attack_interval = 3.0 # Attack every 3 seconds
var is_dead = false
var gravity = 1000.0 # pixels per second squared

# Reference to the AnimatedSprite2D
@onready var animated_sprite_2d = $AnimatedSprite2D

# Timers
@onready var timer = $Timer

# Called when the node enters the scene tree
func _ready():
	timer.timeout.connect(_on_timer_timeout)
	timer.start(1.0) # Check every second

# State machine logic
func _process(delta):
	if is_dead:
		return
	
	match state:
		State.IDLE:
			animated_sprite_2d.play("idle")
			if target:
				_transition_to(State.WALK)

		State.WALK:
			animated_sprite_2d.play("demon_walk")
			_move_toward_target(delta)
			if attack_timer >= attack_interval:
				_transition_to(State.ATTACK)
			attack_timer += delta

		State.ATTACK:
			animated_sprite_2d.play("demon_cleave")
			_deal_damage_to_target()
			_transition_to(State.IDLE)

		State.TAKE_HIT:
			animated_sprite_2d.play("demon_take_hit")
			_transition_to(State.IDLE)

		State.DEATH:
			animated_sprite_2d.play("demon_death")
			is_dead = true
			queue_free() # Remove boss from the scene

# Apply gravity and movement
func _physics_process(delta):
	if not is_dead:
		var velocity = Vector2(0, gravity * delta)

		# Add vertical gravity and horizontal movement
		if target and state == State.WALK:
			var direction = (target.global_position - global_position).normalized()
			velocity.x = direction.x * speed

		velocity = move_and_slide()

# Move toward the player or target
func _move_toward_target(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity.x = direction.x * speed

# Deal damage to the target
func _deal_damage_to_target():
	if target:
		# You can add damage logic here
		print("Dealing damage to the target")
		target.take_damage(1)

# Transition between states
func _transition_to(new_state):
	state = new_state
	attack_timer = 0.0

# Handle being hit
func _on_hit(damage):
	health -= damage
	if health <= 0:
		_transition_to(State.DEATH)
	else:
		_transition_to(State.TAKE_HIT)

# Timer timeout function
func _on_timer_timeout():
	if not target:
		var target = get_tree().get_root().get_node("Player")

	if not is_dead and state == State.IDLE:
		_transition_to(State.WALK)
