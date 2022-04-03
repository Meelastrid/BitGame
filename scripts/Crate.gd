extends StaticBody2D

onready var tilemap : TileMap = get_node("/root/Main/Navigation2D/TileMap")
onready var medkit : PackedScene = preload("res://scenes/Medkit.tscn")

onready var possible_loot = [medkit, medkit, medkit]
var probability : int = 50 # 50% chance


func _ready():
    randomize()
func take_damage():
    print("Took damage!")
    var local_position = tilemap.world_to_map(global_position)
    tilemap.set_cellv(local_position, 0) # 0 = grass
    drop_loot()
    queue_free()

func drop_loot():
    if (randi() % 100) > probability: 
        drop_random_item()

func drop_random_item():
    var item = randi() % 3
    var ins = possible_loot[item].instance()
    $"..".add_child(ins)
    $"..".move_child(ins, 1)
    ins.position = position
