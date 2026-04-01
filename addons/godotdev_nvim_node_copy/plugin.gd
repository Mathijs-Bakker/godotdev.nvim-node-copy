@tool
extends EditorPlugin

const MENU_COPY_NODE_PATH := "godotdev.nvim: Copy Node Path"
const MENU_COPY_DOLLAR_REFERENCE := "godotdev.nvim: Copy $ Reference"
const MENU_COPY_GET_NODE := "godotdev.nvim: Copy get_node()"
const MENU_COPY_ONREADY_VAR := "godotdev.nvim: Copy @onready Var"


func _enter_tree() -> void:
	add_tool_menu_item(MENU_COPY_NODE_PATH, _copy_node_path)
	add_tool_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference)
	add_tool_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference)
	add_tool_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_COPY_NODE_PATH)
	remove_tool_menu_item(MENU_COPY_DOLLAR_REFERENCE)
	remove_tool_menu_item(MENU_COPY_GET_NODE)
	remove_tool_menu_item(MENU_COPY_ONREADY_VAR)


func _copy_node_path() -> void:
	var selected := _get_selected_node()
	if selected == null:
		return

	_copy_to_clipboard(_relative_node_path(selected))


func _copy_dollar_reference() -> void:
	var selected := _get_selected_node()
	if selected == null:
		return

	_copy_to_clipboard(_dollar_reference(selected))


func _copy_get_node_reference() -> void:
	var selected := _get_selected_node()
	if selected == null:
		return

	_copy_to_clipboard(_get_node_reference(selected))


func _copy_onready_var() -> void:
	var selected := _get_selected_node()
	if selected == null:
		return

	_copy_to_clipboard(_onready_var_snippet(selected))


func _get_selected_node() -> Node:
	var scene_root := get_editor_interface().get_edited_scene_root()
	if scene_root == null:
		push_warning("godotdev.nvim-node-copy: no edited scene root found")
		return null

	var selection := get_editor_interface().get_selection()
	if selection == null:
		push_warning("godotdev.nvim-node-copy: editor selection is unavailable")
		return null

	var selected_nodes := selection.get_selected_nodes()
	if selected_nodes.is_empty():
		push_warning("godotdev.nvim-node-copy: no node selected")
		return null

	var selected: Node = selected_nodes[0]
	if not scene_root.is_ancestor_of(selected) and selected != scene_root:
		push_warning("godotdev.nvim-node-copy: selected node is not part of the edited scene")
		return null

	return selected


func _relative_node_path(node: Node) -> String:
	var scene_root := get_editor_interface().get_edited_scene_root()
	if node == scene_root:
		return "."

	return str(scene_root.get_path_to(node))


func _dollar_reference(node: Node) -> String:
	var path := _relative_node_path(node)
	if path == ".":
		return "self"

	return "$%s" % path


func _get_node_reference(node: Node) -> String:
	var path := _relative_node_path(node)
	if path == ".":
		return "self"

	return 'get_node("%s")' % path


func _onready_var_snippet(node: Node) -> String:
	var variable_name := _variable_name_for_node(node)
	var type_name := node.get_class()
	var reference := _dollar_reference(node)
	return "@onready var %s: %s = %s" % [variable_name, type_name, reference]


func _variable_name_for_node(node: Node) -> String:
	var base_name := String(node.name).to_snake_case()
	if base_name.is_empty():
		base_name = "node"

	if _starts_with_ascii_digit(base_name):
		base_name = "node_%s" % base_name

	return base_name


func _starts_with_ascii_digit(value: String) -> bool:
	if value.is_empty():
		return false

	var code := value.unicode_at(0)
	return code >= 48 and code <= 57


func _copy_to_clipboard(text: String) -> void:
	DisplayServer.clipboard_set(text)
	print("godotdev.nvim-node-copy: copied `%s`" % text)
