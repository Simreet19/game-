extends Node2D

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
			# Return to idle or walk after getting hit
			_transition_to(State.IDLE)

		State.DEATH:
			animated_sprite_2d.play("demon_death")
			is_dead = true
			queue_free() # Remove boss from the scene

# Move toward the player or target
func _move_toward_target(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta

# Deal damage to the target
func _deal_damage_to_target():
	if target:
		# You can add damage logic here
		print("Dealing damage to the target")

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
		# Look for the player or set a new target (for simplicity)
		target = get_tree().get_root().find_node("Player", true, false)

	if not is_dead and state == State.IDLE:
		_transition_to(State.WALK)
