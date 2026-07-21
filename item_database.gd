extends Node

var items: Dictionary[String, ItemData] = {}

func _ready() -> void:
	_load_items("res://items/")
	print("loaded items into ItemDatabase")
	print(items)
	
func _load_items(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Invalid paths for ItemDatabase: " + path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			_load_items(path + "/" + file_name)
		elif file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
			var clean_name = file_name.trim_suffix(".remap")
			var full_path = path + "/" + clean_name
			var item: ItemData = load(full_path)
			
			if item:
				var item_id = item.item_id
				items[item_id] = item
				
		file_name = dir.get_next()
		
func get_item(id: String) -> ItemData:
	if items.has(id):
		return items[id]
	push_warning("Item ID not found in ItemDatabase: " + id)
	return null
