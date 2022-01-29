extends StaticBody2D


func _ready():
    pass

func take_damage():
    print("Took damage!")
    queue_free()
