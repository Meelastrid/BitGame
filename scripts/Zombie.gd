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
    var a = get_node("/root/Main/Navigation2D/TileMap/Crate")
    var new_path : Navigation2D = get_node("/root/Main/Navigation2D")
    new_path.get_simple_path(position, a.position)
    
    print(new_path)


func take_damage():
    health -= 1
    print("Took damage! Lives remaining: ", health)
    if health <= 0:
        queue_free()

func _physics_process(delta):
    pass

