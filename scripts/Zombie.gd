extends KinematicBody2D

export (int) var speed : = 50.0

var health = 3

onready var path : = PoolVector2Array()

onready var nav_2d : Navigation2D = get_node("/root/Main/Navigation2D")
onready var line_2d : Line2D = get_node("/root/Main/Navigation2D/Line2D")
onready var player : KinematicBody2D = get_node("/root/Main/Navigation2D/TileMap/Player")

func _ready():
    pass

func _physics_process(_delta):
    generate_path()
    move_along_path()

func generate_path():
    var new_path : = nav_2d.get_simple_path(position, player.position)
    line_2d.points = new_path
    path = new_path

func move_along_path():
    var target = path[1]
    var velocity = position.direction_to(target) * speed
    look_at(player.position)
    if position.distance_to(player.position) > 30:
        velocity = move_and_slide(velocity)

func take_damage():
    health -= 1
    print("Took damage! Lives remaining: ", health)
    if health <= 0:
        queue_free()
