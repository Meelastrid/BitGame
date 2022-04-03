extends Node2D
onready var player = preload("res://scenes/Player.tscn")
onready var crate = preload("res://scenes/Crate.tscn")
onready var zombie = preload("res://scenes/Zombie.tscn")
onready var gui = preload("res://scenes/GUI.tscn")

func _ready():
    randomize()
    create_region(16, 9)

func add_gui():
    var ins = gui.instance()
    add_child(ins) 

func create_region(m, n):
    var region_arr = []
    var region_map = preload("res://scenes/Region.tscn")
    add_child(region_map.instance())
    var tilemap : TileMap = get_node("Navigation2D/TileMap")
    tilemap.tile_set = preload("res://assets/tilesets/tileset_exterior.tres")
    var tile_variation = Vector2()
    for i in range(0, m):
        region_arr.append([])
        for j in range(0, n):
            tile_variation.x = randi() % 4
            tilemap.set_cell(i , j, 0, false, false, false, tile_variation)
            region_arr[i].append(0)

    # Place objects
    add_gui()
    for _c in range(1, randi() % 5 + 4):
        place_object_on_tilemap(m, n, region_arr, crate)
    for _c in range(1, randi() % 3 + 2):
        place_object_on_tilemap(m, n, region_arr, zombie)
    place_object_on_tilemap(m, n, region_arr, player)

func gen_crate_position(m, n, region_arr):
    for i in range(randi() % m, m):
        for j in range(randi() % n, n):
            if region_arr[i][j] == 0:
                return Vector2(i,j)
    for i in range(0, m):
        for j in range(0, n):
            if region_arr[i][j] == 0:
                return Vector2(i,j)

func place_object_on_tilemap(m, n, region_arr, object):
    var object_position = gen_crate_position(m, n, region_arr)
    region_arr[object_position.x][object_position.y] += 1
    var tile_center_pos = $Navigation2D/TileMap.map_to_world(object_position)
    var ins = object.instance()
    $Navigation2D/TileMap.add_child(ins)
    ins.global_position = tile_center_pos + Vector2(32, 32)
