extends Node

var drop_tables = {
	"slime_1": {
		"wand": 0.30
	},
	"slime_boss": {
		"staff_of_doom": 1.0
	}
}

func get_drop(enemy_id: String) -> Array[ItemData]:
	var table = drop_tables.get(enemy_id, {})
	var rolled = roll_table_drops(table)
	return rolled
	

func roll_table_drops(table: Dictionary) -> Array[ItemData]:
	var RNG = RandomNumberGenerator.new()
	var rolled: Array[ItemData] = []
	for item_id in table.keys():
		if RNG.randf_range(0,1) < table.get(item_id, 0):
			rolled.append(ItemDatabase.get_item(item_id))
			
	return rolled
