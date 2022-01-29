extends StaticBody2D

onready var tilemap : TileMap = get_node("/root/Main/Navigation2D/TileMap")

func take_damage():
    print("Took damage!")
    var local_position = tilemap.world_to_map(global_position)
    tilemap.set_cellv(local_position, 0) # 0 = grass
    queue_free()
