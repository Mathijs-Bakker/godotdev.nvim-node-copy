@tool
extends EditorPlugin

const MENU_COPY_NODE_PATH := "godotdev.nvim: Copy Node Path"
const MENU_COPY_DOLLAR_REFERENCE := "godotdev.nvim: Copy $ Reference"
const MENU_COPY_GET_NODE := "godotdev.nvim: Copy get_node()"
const MENU_COPY_ONREADY_VAR := "godotdev.nvim: Copy @onready Var"
const MENU_ICON := preload("res://addons/godotdev_nvim_node_copy/assets/godotdev_nvim_icon.svg")

const CONTEXT_ID_COPY_NODE_PATH := 1001
const CONTEXT_ID_COPY_DOLLAR_REFERENCE := 1002
const CONTEXT_ID_COPY_GET_NODE := 1003
const CONTEXT_ID_COPY_ONREADY_VAR := 1004

var _scene_tree_context_menu := SceneTreeContextMenuPlugin.new(self)
var _canvas_item_context_menu := CanvasItemContextMenuPlugin.new(self)


func _enter_tree() -> void:
	add_tool_menu_item(MENU_COPY_NODE_PATH, _copy_node_path)
	add_tool_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference)
	add_tool_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference)
	add_tool_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, _scene_tree_context_menu)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, _canvas_item_context_menu)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_COPY_NODE_PATH)
	remove_tool_menu_item(MENU_COPY_DOLLAR_REFERENCE)
	remove_tool_menu_item(MENU_COPY_GET_NODE)
	remove_tool_menu_item(MENU_COPY_ONREADY_VAR)
	remove_context_menu_plugin(_scene_tree_context_menu)
	remove_context_menu_plugin(_canvas_item_context_menu)


func _copy_node_path() -> void:
	_copy_for_selected_node(func(selected: Node) -> String:
		return _relative_node_path(selected)
	)


func _copy_dollar_reference() -> void:
	_copy_for_selected_node(func(selected: Node) -> String:
		return _dollar_reference(selected)
	)


func _copy_get_node_reference() -> void:
	_copy_for_selected_node(func(selected: Node) -> String:
		return _get_node_reference(selected)
	)


func _copy_onready_var() -> void:
	_copy_for_selected_node(func(selected: Node) -> String:
		return _onready_var_snippet(selected)
	)


func _copy_for_selected_node(renderer: Callable) -> void:
	var selected := _get_selected_node()
	if selected == null:
		return

	_copy_to_clipboard(renderer.call(selected))


func _copy_for_node(node: Node, renderer: Callable) -> void:
	if node == null:
		return

	_copy_to_clipboard(renderer.call(node))


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


class SceneTreeContextMenuPlugin extends EditorContextMenuPlugin:
	var _plugin: EditorPlugin


	func _init(plugin: EditorPlugin) -> void:
		_plugin = plugin


	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.is_empty():
			return

		add_context_menu_item(MENU_COPY_NODE_PATH, _copy_node_path_context, MENU_ICON)
		add_context_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference_context, MENU_ICON)
		add_context_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference_context, MENU_ICON)
		add_context_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var_context, MENU_ICON)


	func _copy_node_path_context(_selection: Array) -> void:
		var node: Node = (_plugin as EditorPlugin)._get_selected_node()
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._relative_node_path(selected)
		)


	func _copy_dollar_reference_context(_selection: Array) -> void:
		var node: Node = (_plugin as EditorPlugin)._get_selected_node()
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._dollar_reference(selected)
		)


	func _copy_get_node_reference_context(_selection: Array) -> void:
		var node: Node = (_plugin as EditorPlugin)._get_selected_node()
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._get_node_reference(selected)
		)


	func _copy_onready_var_context(_selection: Array) -> void:
		var node: Node = (_plugin as EditorPlugin)._get_selected_node()
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._onready_var_snippet(selected)
		)


class CanvasItemContextMenuPlugin extends EditorContextMenuPlugin:
	var _plugin: EditorPlugin


	func _init(plugin: EditorPlugin) -> void:
		_plugin = plugin


	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.is_empty():
			return

		add_context_menu_item(MENU_COPY_NODE_PATH, _copy_node_path_context, MENU_ICON)
		add_context_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference_context, MENU_ICON)
		add_context_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference_context, MENU_ICON)
		add_context_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var_context, MENU_ICON)


	func _copy_node_path_context(selection: Array) -> void:
		var node: Node = _node_from_selection(selection)
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._relative_node_path(selected)
		)


	func _copy_dollar_reference_context(selection: Array) -> void:
		var node: Node = _node_from_selection(selection)
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._dollar_reference(selected)
		)


	func _copy_get_node_reference_context(selection: Array) -> void:
		var node: Node = _node_from_selection(selection)
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._get_node_reference(selected)
		)


	func _copy_onready_var_context(selection: Array) -> void:
		var node: Node = _node_from_selection(selection)
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._onready_var_snippet(selected)
		)


	func _node_from_selection(selection: Array) -> Node:
		if selection.is_empty():
			return null

		if selection[0] is Node:
			return selection[0] as Node

		push_warning("godotdev.nvim-node-copy: 2D context menu selection did not resolve to a node")
		return null
