@tool
extends EditorPlugin

func _enter_tree():
	add_tool_menu_item("Create BaseMaterial3D", Callable(self, "on_menu_item_selected"))

func _exit_tree():
	remove_tool_menu_item("Create BaseMaterial3D")

func on_menu_item_selected():
	var my_command_script = load("res://addons/EditorToolbox/MyEditorCommand1.gd").new()
	my_command_script.execute()
