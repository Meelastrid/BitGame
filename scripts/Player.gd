extends KinematicBody2D

export (int) var speed = 200

var target = position
var velocity = Vector2()
var moving = false
var health = 20
var max_health = 20
onready var animation_player = $WeaponPivot/Sword/AnimationPlayer
onready var hp_gui : Label = get_node("/root/Main/GUI/HBoxContainer/HPValue")

func _ready():
    animation_player.play("RESET")
    hp_gui.text = str(health)

func rotate_to_mouse():
    look_at(get_global_mouse_position())

func _unhandled_input(event):
    target = get_global_mouse_position()
    if event.is_action_pressed("right_click"):
        moving = true
    if event.is_action_pressed("left_click"):
        print("Attacking")
        animation_player.play("attack")

func _physics_process(_delta):
    look_at(target)
    if moving:
        velocity = position.direction_to(target) * speed
        if position.distance_to(target) > 5:
            velocity = move_and_slide(velocity)
        else:
            moving = false

func take_damage():
    health -= 1
    hp_gui.text = str(health)
    if health <= 0:
        queue_free()

func heal(n):
    if health + n > max_health:
        health = max_health
    else:
        health += n
    hp_gui.text = str(health)
