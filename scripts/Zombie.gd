extends KinematicBody2D

export (int) var speed = 150

var health = 3
var RotateSpeed = 5
var Radius = 100
var _centre
var _angle = 0
func _ready():
    set_process(true)
    _centre = position


func take_damage():
    health -= 1
    print("Took damage! Lives remaining: ", health)
    if health <= 0:
        queue_free()

func _physics_process(delta):
    pass
#    _angle += RotateSpeed * delta;
#    var offset = Vector2(sin(_angle), cos(_angle)) * Radius;
#    var pos = _centre + offset
#    move_and_slide(pos)
