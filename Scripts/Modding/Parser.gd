# This is part of the Modding capability feature by TJ (GMT)#8065
# This uses a custom language, named KOCM, for easier accessibility with KoC.
# This is based off of the old KoC Modded Clients, for v1.9.3-v1.10.0, which used GDScript.
#
# This is the PARSER part of the Modding feature.

extends Node

static func printf(st=""):
	if st != "": print("[KOCM/Parser] "+str(st))

# This function returns a list of KOCM descriptors.
# Descriptors are used to designate information on a file, such as its name.
static func getDescriptors():
	return ["@name", "@authors", "@version", "@runtime"]
static func getDescriptorsDefaults():
	return ["Unnamed Mod", "No authors.", "1.0.0", "worldLoad"]
	
# This function returns a list of KOCM line terminators.
# Line terminators are used to allow for more compact code.
static func getLineTerminators(includeNewlines:bool=false):
	var base = [";", "{", "}"]
	if includeNewlines: base.append_array(["\n", "\r"]);return base
	else: 
		var toAdd = []
		for term in base:
			toAdd.append_array([term+"\n",term+"\r",term+"\n\r"])
		base.append_array(toAdd);
		return base
		
# This function returns a list of KOCM elements.
# This is the one of the most complex get functions in this file, considering t-
#-hat it has to contain both KOCM references and executor references.
static func getElements():
	return {
		"Player": ["[World]Entities/Player", {
			"Visible": ["Boolean", "$.visible"],
			"Scale": ["Vector", "$.scale"],
			"Position": ["Vector", "$.position"],
			"Rotation": ["Integer", "$.rotation"],
			"ZIndex": ["Integer", "$.z_index"],
			"LinkedScript": ["String", "$.get_script()"],
			"Speed": ["Integer", "$.£(\"Speed\")"] # £ is either SET or GET (executor handled)
		}]
	}
	
# This function returns a list of KOCM functions.
# Functions are used in KOCM in a format to the example:
# print;{"arg1", "arg2", 3, 4};
static func getFunctions():
	return ["print"]
	
# This function trims newlines from a string.
static func trimNewlines(string):
	return string.replace("\n", "").replace("\r", "")
static func escapeNewlines(string):
	return string.replace("\n", "\\n").replace("\r", "\\r")
	
# This function returns a list of valid line starters.
# This uses all previous get functions.
static func getLineStarters(suffix=""):
	var final = []
	for x in getFunctions(): final.append(x)
	for x in getDescriptors(): final.append(x+str(suffix))
	for x in getElements(): final.append(x+str(suffix))
	return final
	
# Utility functions.
static func endsWithMultiple(string, array):
	var ends = false;for x in array:if string.ends_with(x): ends = true;
	return ends
static func beginsWithMultiple(string, array):
	var begins = false;for x in array:if string.begins_with(x): begins = true;
	return begins
static func isEmpty(string):
	var empty = false;
	for x in getLineTerminators(true):
		if string == x: 
			empty = true;
	return empty
	
# This function returns a KOCM mod file as line-terminator-separated lines.
static func getLinesOfModFile(modFile, _silent=false):
	return trimNewlines(FileAccess.open("user://mods/"+str(modFile), FileAccess.READ).get_as_text()).split(";")

# This function handles parsing the entire KOCM mod file.
# This is more complex, only touch if you know what you're doing
static func parse(pathToFile, silent=false):
	var modFile = FileAccess.open(pathToFile, FileAccess.READ)
	var modFileName = str(pathToFile.split("/")[pathToFile.split("/").size()-1])
	var modLines = trimNewlines(modFile.get_as_text()).split(";")
	var parserFormatValidationLine = 0
	var hasErroredDuringParsing = false
	for line in modFile.get_as_text().split("\n"):
		var nline = escapeNewlines(line)
		parserFormatValidationLine += 1
		if not isEmpty(line): # Prevent parsing empty lines.
			if not endsWithMultiple(line, getLineTerminators()):
				hasErroredDuringParsing = true
				if silent == false:
					printf("Missing line terminator on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
					printf("  - "+nline)
					printf("  - Ended with \""+escapeNewlines(line.split()[line.split().size()-1])+"\" instead of any allowed line terminator.")
			if not beginsWithMultiple(line, getLineStarters()):
				hasErroredDuringParsing = true
				if silent == false:
					printf("Invalid line starter on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
					printf("  - "+nline)
					printf("  - Started with an invalid line starter.")
			else:
				if beginsWithMultiple(line, getLineStarters(".")) and trimNewlines(line).replace(" = ","=").split("=")[0].split(".").size() > 1:
					var lc = trimNewlines(line).replace(" = ","=").split("=")
					var args = lc[0].split(".")
					var telement = str(args[0]).split(" ")[str(args[0]).split(" ").size()-1]
					var fixedLastArg = args[args.size()-1].replace(";", "")
					if getElements().has(telement):
						pass
#						if getElements().get(telement)[1].has(fixedLastArg): pass # This is the furthest check you can do as of now.
#						else:
#							hasErroredDuringParsing = true
#							if silent == false:
#								printf("Invalid attribute for \""+str(args[0])+"\" on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
#								printf("  - "+nline)
#								printf("  - Attempted to get/set an invalid attribute of an element.")
					else:
						hasErroredDuringParsing = true
						if silent == false:
							printf("Attempt to get/set attribute of non-element \""+telement+"\" on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
							printf("  - "+nline)
							printf("  - Attempted to get/set attribute of a non-element object.")
	if hasErroredDuringParsing:
		if silent == false:
			printf("Unable to load Mod "+modFileName+" due to parsing errors.")
		return [false, null]
	else:
		var modInformation = {"file": modFile.get_path().split("/")[modFile.get_path().split("/").size()-1]}
		var miind = 0
		for descriptor in getDescriptors(): 
			modInformation.merge(
				{descriptor.replace("@", ""): 
				getDescriptorsDefaults()[miind]}
			, true)
			miind += 1
		
		for modLine in modLines:
			for descriptor in getDescriptors():
				if modLine.begins_with(descriptor):
					var tempmi = {descriptor.replace("@", ""): modLine.replace(descriptor+" ","")}
					modInformation.merge(tempmi, true)
			
		if silent == false:
			printf("Parsed mod "+str(modInformation["name"])+" v"+str(modInformation["version"])+".")
		return [true, modInformation]
