extends Area2D

onready var entered_bodies = []

func _clear_entered_bodies():
    entered_bodies = []

func _on_Sword_body_entered(body):
    if body.is_in_group("hurtbox"):
        if not (body in entered_bodies):
            entered_bodies.append(body)
            body.take_damage()
