extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func take_damage():
    print("Took damage!")
    queue_free()


func _process(delta):
    pass
