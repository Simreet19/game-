extends Control
# Called when the node enters the scene tree for the first time.

# Preload your background textures
var backgrounds = [
	preload("res://Assets/bg11.jpg"),
	#preload("res://Assets/bg/WhatsApp Image 2024-10-19 at 4.51.51 PM.jpeg"),
	#preload("res://Assets/characters/p1.jpg")
]
@onready var animated_sprite_2d = $Panel/AnimatedSprite2D
@onready var animated_sprite_2d2 = $Panel/AnimatedSprite2D2
@onready var animated_sprite_2d3 = $Panel/AnimatedSprite2D3
@onready var player_1 = $Player1
@onready var player_2 = $Player2
@onready var player_3 = $Player3

# Reference to the TextureRect node
@onready var texture_rect = $Panel/TextureRect

func _ready():
	# Set the initial background
	texture_rect.texture = backgrounds[0]  # Set the initial background to the first one
	player_1.pressed.connect(self._on_Button_pressed_1)
	player_2.pressed.connect(self._on_Button_pressed_2)
	player_3.pressed.connect(self._on_Button_pressed_3)
	animated_sprite_2d.hide()
	animated_sprite_2d2.hide()
	animated_sprite_2d3.hide()
	


func _on_Button_pressed_1():
	# Change to the first background
	animated_sprite_2d.show();
	animated_sprite_2d.play()
	animated_sprite_2d2.hide()
	animated_sprite_2d3.hide()

func _on_Button_pressed_2():
	# Change to the second background
	animated_sprite_2d3.show();
	animated_sprite_2d3.play()
	animated_sprite_2d.hide()
	animated_sprite_2d2.hide()

func _on_Button_pressed_3():
	# Change to the third background
	animated_sprite_2d2.show();
	animated_sprite_2d2.play()
	animated_sprite_2d.hide()
	animated_sprite_2d3.hide()
