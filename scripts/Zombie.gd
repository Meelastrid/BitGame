extends KinematicBody2D

export (int) var speed : = 100.0

var health = 3
var wandering = true

onready var nav_2d : Navigation2D = get_node("/root/Main/Navigation2D")
onready var tilemap : TileMap = get_node("/root/Main/Navigation2D/TileMap")
onready var player : KinematicBody2D = get_node("/root/Main/Navigation2D/TileMap/Player")
onready var line_2d : Line2D = get_node("/root/Main/Navigation2D/Line2D")
onready var animation_player = $WeaponPivot/Bone/AnimationPlayer

onready var path : = PoolVector2Array()
onready var dest : Vector2 = gen_random_position()

func _ready():
    randomize()

func _physics_process(_delta):
    if global_position.distance_to(player.global_position) > 200:
        wandering = true
    else:
        wandering = false
    if wandering:
        if global_position.distance_to(dest) < 32:
            dest = gen_random_position()
    else:
        dest = player.global_position
    look_at(dest)
    generate_path(dest)
    move_along_path()
    if global_position.distance_to(player.global_position) < 50:
        animation_player.play("attack")

func gen_random_position():
    var viewport = get_viewport_rect().size
    var x_range = Vector2(10, viewport.x)
    var y_range = Vector2(10, viewport.y)
    var random_x = randi() % int(x_range[1]- x_range[0]) + 1 + x_range[0] 
    var random_y =  randi() % int(y_range[1]-y_range[0]) + 1 + y_range[0]
    var random_pos = Vector2(random_x, random_y)
    return random_pos
    
func wander():
    if wandering:
        pass
        
func generate_path(target):
    var new_path : = nav_2d.get_simple_path(global_position, target)
    line_2d.points = new_path
    path = new_path

func move_along_path():
    var target = path[1]
    var velocity = global_position.direction_to(target) * speed
    if global_position.distance_to(player.global_position) > 30:
        velocity = move_and_slide(velocity)

func take_damage():
    health -= 1
    print("Took damage! Lives remaining: ", health)
    if health <= 0:
        queue_free()
