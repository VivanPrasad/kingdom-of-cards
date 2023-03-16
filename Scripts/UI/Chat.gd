extends Control

@export var isInputActive = false
var messages = 0

func _ready():
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func removeOldMessages(crd=0):
	crd += 1
	messages -= 1
	$ChatPanel.get_child(1).queue_free()
	if messages > 10: return removeOldMessages(crd)
	else: return crd
	
func _input(event):
	if event.is_action_released("ui_accept") and $ChatInput.text != "":
		var entry = $ChatInput.text
		var user = "Player" # change to be some get for multiplayer when added
		var ChatMessage = $Templates/ChatMessage.duplicate()
		if $ChatPanel.get_child_count() >= 10:
			var removedChildren = removeOldMessages()
			for child in $ChatPanel.get_children():
				child.position.y = child.position.y - (52*removedChildren)
		ChatMessage.get_node("Sender").text = user
		ChatMessage.get_node("Message").text = entry
		ChatMessage.position.y = 52+(52*(messages-1))
		messages += 1
		$ChatPanel.add_child(ChatMessage)
		$ChatInput.text = ""

func _on_chat_input_mouse_entered(): isInputActive = true
func _on_chat_input_mouse_exited(): isInputActive = false
