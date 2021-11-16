extends Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _input(event):
    # Mouse in viewport coordinates.
    if event.is_action_pressed("left_click"):
        position = get_viewport().get_mouse_position()
        print("Mouse Click/Unclick at: ", get_viewport().get_mouse_position())
