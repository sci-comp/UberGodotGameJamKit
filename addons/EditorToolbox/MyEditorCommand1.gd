@tool
extends Object

func execute():
	
	var dir = DirAccess.open("res://Temp")
	dir.list_dir_begin()
	var texture_files = []
	var normal_suffix = "_n.png"
	
	while true:
		var filename = dir.get_next()
		
		if filename == "":
			break
			
		if filename.ends_with(".import"):
			continue
		
		if filename.begins_with("T_"):
			texture_files.append(filename)
	
	for filename in texture_files:
		
		if filename.ends_with(normal_suffix):
			print("normal map, continue...")
			continue
			
		var base_name = filename.get_basename()
		print(base_name)
		var mat = StandardMaterial3D.new()
		
		var albedo_texture = load("res://Temp/" + filename)
		mat.albedo_texture = albedo_texture
		
		var normal_found = false
		var normal_filename = base_name + normal_suffix
		
		if normal_filename in texture_files:
			var normal_texture = load("res://Temp/" + normal_filename)
			mat.normal_enabled = true
			mat.normal_texture = normal_texture
			normal_found = true
		
		if not normal_found:
			print("normal map not found: " + normal_filename)
		
		var material_path = "res://Temp/MI_" + base_name.substr(2) + ".tres"
		ResourceSaver.save(mat, material_path)
