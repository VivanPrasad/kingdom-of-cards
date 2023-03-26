extends Control

@export var isInputActive = false
var messages = 0

func _ready():
	self.visible = true
	$ChatWindow.visible = false
	$UnreadNotifier.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $UnreadNotifier.visible and $ChatWindow.visible: 
		$UnreadNotifier.visible = false
func removeOldMessages(crd=0):
	crd += 1
	messages -= 1
	$ChatPanel.get_child(1).queue_free()
	if messages > 10: return removeOldMessages(crd)
	else: return crd
	
func addMessage(sender, message):
	var ChatMessage = $ChatWindow/Templates/ChatMessage.duplicate()
	if $ChatWindow/ChatPanel.get_child_count() >= 10:
		var removedChildren = removeOldMessages()
		for child in $ChatWindow/ChatPanel.get_children():
			child.position.y = child.position.y - (52*removedChildren)
	ChatMessage.get_node("Sender").text = sender
	ChatMessage.get_node("Message").text = message
	ChatMessage.position.y = 52+(52*(messages-1))
	messages += 1
	$ChatWindow/ChatPanel.add_child(ChatMessage)
	if $ChatWindow.visible == false:
		$UnreadNotifier.visible = true

func _input(event):
	if event.is_action_released("ui_accept") and $ChatWindow/ChatInput.text != "":
		var entry = $ChatWindow/ChatInput.text
		var user = "Player" # change to be some get for multiplayer when added
		if $ChatWindow/ChatInput.text.begins_with("/"):
			var args = $ChatWindow/ChatInput.text.split(" ")
			var response = "Invalid command. Type '/help' for a list of all available commands."
			if args[0] == "/help":
				response = "The only available command as of now is '/help', which you are seeing right now."
			addMessage("System", response)
		else:
			addMessage(user, entry)
		$ChatWindow/ChatInput.text = ""

func _on_chat_input_mouse_entered(): isInputActive = true
func _on_chat_input_mouse_exited(): isInputActive = false
