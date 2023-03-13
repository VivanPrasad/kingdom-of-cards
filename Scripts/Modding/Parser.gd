# This is part of the Modding capability feature by TJ (GMT)#8065
# This uses a custom language, named KOCM, for easier accessibility with KoC.
# This is based off of the old KoC Modded Clients, for v1.9.3-v1.10.0, which used GDScript.
#
# This is the PARSER part of the Modding feature.

extends Node

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
	
# This function trims newlines from a string.
static func trimNewlines(string):
	return string.replace("\n", "").replace("\r", "")
static func escapeNewlines(string):
	return string.replace("\n", "\\n").replace("\r", "\\r")
	
# This function returns a list of valid line starters.
# This uses all previous get functions.
static func getLineStarters(suffix=""):
	var final = []
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

# This function handles parsing the entire KOCM mod file.
# This is more complex, only touch if you know what you're doing
static func parse(pathToFile):
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
				print("Missing line terminator on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
				print("  - "+nline)
				print("  - Ended with \""+escapeNewlines(line.split()[line.split().size()-1])+"\" instead of any allowed line terminator.")
			if not beginsWithMultiple(line, getLineStarters()):
				hasErroredDuringParsing = true
				print("Invalid line starter on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
				print("  - "+nline)
				print("  - Started with an invalid line starter.")
			else:
				if beginsWithMultiple(line, getLineStarters(".")):
					var lc = trimNewlines(line).replace(" = ","=").split("=")
					var args = lc[0].split(".")
					var fixedArg1 = args[1].replace(";", "")
					if getElements().has(args[0]):
						if getElements().get(args[0])[1].has(fixedArg1): pass # This is the furthest check you can do as of now.
						else:
							hasErroredDuringParsing = true
							print("Invalid attribute for \""+str(args[0])+"\" on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
							print("  - "+nline)
							print("  - Attempted to get/set an invalid attribute of an element.")
					else:
						hasErroredDuringParsing = true
						print("Attempt to get/set attribute of non-element \""+str(args[0])+"\" on Line "+str(parserFormatValidationLine)+" of Mod "+modFileName)
						print("  - "+nline)
						print("  - Attempted to get/set attribute of a non-element object.")
	if hasErroredDuringParsing:
		print("Unable to load Mod "+modFileName+" due to parsing errors.")
		return false
	else:
		var modInformation = {}
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
			
		print("Parsed mod "+str(modInformation["name"])+" v"+str(modInformation["version"])+".")
		return true
