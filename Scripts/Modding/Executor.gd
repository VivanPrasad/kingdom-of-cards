# This is part of the Modding capability feature by TJ (GMT)#8065
# This uses a custom language, named KOCM, for easier accessibility with KoC.
# This is based off of the old KoC Modded Clients, for v1.9.3-v1.10.0, which used GDScript.
#
# This is the EXECUTOR part of the Modding feature.
#
# This is the most complex part of the entire Modding feature, considering it has
# to hook into each class which has been given mod support (e.g. World) and hook
# into the Parser to read code lines more accurately.
#
# If you try to do something and it doesn't work, add on to the counter below.
# global_hours_wasted_here = 0

extends Node

static func printf(st=""):
	if st != "": print("[KOCM/Executor] "+str(st))
	
static func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	var obj = RefCounted.new()
	obj.set_script(script)
	return obj.eval()
	
static func findModByFile(_modFileName):
	var dir = DirAccess.open("user://mods")
	if dir != null:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and file.split(".")[file.split(".").size()-1] == "kocm":#
				return [true, FileAccess.open("user://mods/"+file, FileAccess.READ).get_as_text()]
		dir.list_dir_end()
		return [false, null]

static func printm(mod, st):
		print("[KOCM/Mod/"+mod+"] "+st)
static func runMod(modFileName):
	var modData = findModByFile(modFileName)
	var parser = load("res://Scripts/Modding/Parser.gd")
	if modData[0] == true:
		printf("Attempting to execute mod \""+modFileName+"\".")
		var lines = parser.getLinesOfModFile(modFileName)
		for line in lines:
			if not parser.beginsWithMultiple(line, parser.getDescriptors()):
				if parser.beginsWithMultiple(line, parser.getFunctions()):
					var args = []
					var i = 0
					for x in line.split(" "):
						if i != 0:
							args.append(x)
						i += 1#
					if line.begins_with("print"):
						var printout = ""
						for arg in args:
							var executedArg = arg
							var elements = parser.getElements()
							if parser.beginsWithMultiple(arg, elements):
								var temp = elements.get(arg.split(".")[0])[1].get(arg.split(".")[1])[1].replace("£", "get")
								var locator = elements.get(arg.split(".")[0])[0]
								var locargs = temp.replace("$", locator.split("]")[1]).split(".")
								var code = 'load("res://Scenes/Game/'+locator.split("]")[0].replace("[","")+'.tscn").instantiate().get_node("'+locargs[0]+'").'+locargs[1]
								executedArg=evaluate(code)
							printout = str(printout)+str(executedArg)+" "
						printm(modFileName, printout)
	else:
		printf("Unknown mod "+str(modFileName))
		printf("  - "+modFileName)
		printf("  - Are you sure this mod still exists since game start?")
			
