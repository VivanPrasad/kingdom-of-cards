# This is part of the Modding capability feature by TJ (GMT)#8065
# This uses a custom language, named KOCM, for easier accessibility with KoC.
# This is based off of the old KoC Modded Clients, for v1.9.3-v1.10.0, which used GDScript.
#
# This is the EXECUTOR part of the Modding feature.
#
# This is the most complex part of the entire Modding feature, considering it has
# to hook into each class which has been given mod support (e.g. World) and hook
# into the Parser to read code lines more accurately.

extends Node

static func printf(st=""):
	if st != "": print("[KOCM/Executor] "+str(st))
	
static func evaluate(input, targnode:Node2D):
	var script = GDScript.new()
	@warning_ignore("unused_variable")
	var doReturn = true
	input = input.replace("<>", "get_tree().get_current_scene()")
	script.set_source_code("extends Node2D\nfunc exec():\n\treturn "+input)
	if input.contains(".set("): 
		script.set_source_code("extends Node2D\nfunc exec():\n\t"+input+"\n\treturn 0")
		doReturn = false
	var obj = Node2D.new()
	targnode.add_child(obj)
	script.reload()
	obj.set_script(script)
	return obj.exec()
	
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
static func runMod(modFileName, targnode:Node2D):
	var modData = findModByFile(modFileName)
	var parser = load("res://Scripts/Modding/Parser.gd")
	if modData[0] == true:
		printf("Attempting to execute mod \""+modFileName+"\".")
		var lines = parser.getLinesOfModFile(modFileName)
		for line in lines:
			if not parser.beginsWithMultiple(line, parser.getDescriptors()):
				var elements = parser.getElements()
				if parser.beginsWithMultiple(line, elements):
					var args = line.replace(" = ", "=").split("=")
					var temp = elements.get(args[0].split(".")[0])[1].get(args[0].split(".")[1])[1].replace("£", "set")
					var locator = elements.get(args[0].split(".")[0])[0]
					var locargs = temp.replace("$", locator.split("]")[1]).split(".")
					var setsect = locargs[1].replace(")", ", "+str(args[1])+")")
					var code = '<>.get_node("'+locargs[0]+'").'+setsect
					evaluate(code, targnode)
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
							if parser.beginsWithMultiple(arg, elements):
								var temp = elements.get(arg.split(".")[0])[1].get(arg.split(".")[1])[1].replace("£", "get")
								var locator = elements.get(arg.split(".")[0])[0]
								var locargs = temp.replace("$", locator.split("]")[1]).split(".")
								var code = '<>.get_node("'+locargs[0]+'").'+locargs[1]
								executedArg=evaluate(code, targnode)
							printout = str(printout)+str(executedArg)+" "
						printm(modFileName, printout)
	else:
		printf("Unknown mod "+str(modFileName))
		printf("  - "+modFileName)
		printf("  - Are you sure this mod still exists since game start?")
			
