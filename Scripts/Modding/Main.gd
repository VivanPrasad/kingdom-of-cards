# This is part of the Modding capability feature by TJ (GMT)#8065
# This uses a custom language, named KOCM, for easier accessibility with KoC.
# This is based off of the old KoC Modded Clients, for v1.9.3-v1.10.0, which used GDScript.
#
# This is the INITIALISER part of the Modding feature.

extends Node

static func list_files_in_directory(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and file.split(".")[file.split(".").size()-1] == "kocm":
				files.append(file)
		dir.list_dir_end()
		return files
	else:
		print("Creating directory: "+path)
		DirAccess.make_dir_recursive_absolute(path)
		return list_files_in_directory(path)

static func start():
	print("Searching for mods...")
	var mods = list_files_in_directory("user://mods")
	if mods != null: 
		print("Found: "+str(mods.size())+" mods.")
		print("Beginning mod loading sequence... (Execute order 66)")
		var parser = load("res://Scripts/Modding/Parser.gd")
		var successedMods = 0
		for mod in mods:
			var result = parser.parse("user://mods/"+mod)
			if result: successedMods += 1
		print(str(successedMods)+"/"+str(mods.size())+" mods successfully loaded.")
	else: "Found no mods."
