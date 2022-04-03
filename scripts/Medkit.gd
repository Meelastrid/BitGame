extends Area2D

func _ready():
    pass # Replace with function body.


func _on_Area2D_body_entered(body):
    if body.is_in_group("player"):
        body.heal(1)
    queue_free()
