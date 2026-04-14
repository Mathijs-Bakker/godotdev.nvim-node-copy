@tool
extends EditorPlugin

const MENU_COPY_NODE_PATH := "godotdev.nvim: Copy Node Path"
const MENU_COPY_DOLLAR_REFERENCE := "godotdev.nvim: Copy $ Reference"
const MENU_COPY_GET_NODE := "godotdev.nvim: Copy get_node()"
const MENU_COPY_ONREADY_VAR := "godotdev.nvim: Copy @onready Var"
const MENU_COPY_CSHARP_GET_NODE := "godotdev.nvim: Copy C# GetNode<T>()"
const MENU_COPY_CSHARP_PROPERTY := "godotdev.nvim: Copy C# Property"
const MENU_ICON := preload("res://addons/godotdev_nvim_node_copy/assets/godotdev_nvim_icon.svg")
const SETTING_ENABLE_GDSCRIPT := "godotdev_nvim_node_copy/enable_gdscript"
const SETTING_ENABLE_CSHARP := "godotdev_nvim_node_copy/enable_csharp"
const SETTING_OUTPUT_MODE := "godotdev_nvim_node_copy/output/mode"
const SETTING_NEOVIM_EXECUTABLE := "godotdev_nvim_node_copy/output/neovim_executable"
const SETTING_NEOVIM_SERVER_ADDRESS := "godotdev_nvim_node_copy/output/neovim_server_address"
const SETTING_FALLBACK_TO_CLIPBOARD := "godotdev_nvim_node_copy/output/fallback_to_clipboard"
const OUTPUT_MODE_CLIPBOARD := "clipboard"
const OUTPUT_MODE_NEOVIM := "neovim_remote"
const DEFAULT_UNIX_SERVER_ADDRESS := "/tmp/godot.nvim"
const DEFAULT_WINDOWS_SERVER_ADDRESS := "\\\\.\\pipe\\godot.nvim"

const CONTEXT_ID_COPY_NODE_PATH := 1001
const CONTEXT_ID_COPY_DOLLAR_REFERENCE := 1002
const CONTEXT_ID_COPY_GET_NODE := 1003
const CONTEXT_ID_COPY_ONREADY_VAR := 1004

var _scene_tree_context_menu := SceneTreeContextMenuPlugin.new(self)
var _canvas_item_context_menu := CanvasItemContextMenuPlugin.new(self)


func _enter_tree() -> void:
	_register_settings()
	_add_tool_menu_items()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, _scene_tree_context_menu)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, _canvas_item_context_menu)


func _exit_tree() -> void:
	_remove_tool_menu_items()
	remove_context_menu_plugin(_scene_tree_context_menu)
	remove_context_menu_plugin(_canvas_item_context_menu)


func _register_settings() -> void:
	if not ProjectSettings.has_setting(SETTING_ENABLE_GDSCRIPT):
		ProjectSettings.set_setting(SETTING_ENABLE_GDSCRIPT, true)
		ProjectSettings.set_initial_value(SETTING_ENABLE_GDSCRIPT, true)
		ProjectSettings.add_property_info({
			"name": SETTING_ENABLE_GDSCRIPT,
			"type": TYPE_BOOL,
		})

	if not ProjectSettings.has_setting(SETTING_ENABLE_CSHARP):
		ProjectSettings.set_setting(SETTING_ENABLE_CSHARP, true)
		ProjectSettings.set_initial_value(SETTING_ENABLE_CSHARP, true)
		ProjectSettings.add_property_info({
			"name": SETTING_ENABLE_CSHARP,
			"type": TYPE_BOOL,
		})

	if not ProjectSettings.has_setting(SETTING_OUTPUT_MODE):
		ProjectSettings.set_setting(SETTING_OUTPUT_MODE, OUTPUT_MODE_CLIPBOARD)
		ProjectSettings.set_initial_value(SETTING_OUTPUT_MODE, OUTPUT_MODE_CLIPBOARD)
		ProjectSettings.add_property_info({
			"name": SETTING_OUTPUT_MODE,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "clipboard,neovim_remote",
		})

	if not ProjectSettings.has_setting(SETTING_NEOVIM_EXECUTABLE):
		ProjectSettings.set_setting(SETTING_NEOVIM_EXECUTABLE, "nvr")
		ProjectSettings.set_initial_value(SETTING_NEOVIM_EXECUTABLE, "nvr")
		ProjectSettings.add_property_info({
			"name": SETTING_NEOVIM_EXECUTABLE,
			"type": TYPE_STRING,
		})

	if not ProjectSettings.has_setting(SETTING_NEOVIM_SERVER_ADDRESS):
		var default_server_address := _default_neovim_server_address()
		ProjectSettings.set_setting(SETTING_NEOVIM_SERVER_ADDRESS, default_server_address)
		ProjectSettings.set_initial_value(SETTING_NEOVIM_SERVER_ADDRESS, default_server_address)
		ProjectSettings.add_property_info({
			"name": SETTING_NEOVIM_SERVER_ADDRESS,
			"type": TYPE_STRING,
		})

	if not ProjectSettings.has_setting(SETTING_FALLBACK_TO_CLIPBOARD):
		ProjectSettings.set_setting(SETTING_FALLBACK_TO_CLIPBOARD, true)
		ProjectSettings.set_initial_value(SETTING_FALLBACK_TO_CLIPBOARD, true)
		ProjectSettings.add_property_info({
			"name": SETTING_FALLBACK_TO_CLIPBOARD,
			"type": TYPE_BOOL,
		})


func _gdscript_enabled() -> bool:
	return bool(ProjectSettings.get_setting(SETTING_ENABLE_GDSCRIPT, true))


func _csharp_enabled() -> bool:
	return bool(ProjectSettings.get_setting(SETTING_ENABLE_CSHARP, true))


func _output_mode() -> String:
	return String(ProjectSettings.get_setting(SETTING_OUTPUT_MODE, OUTPUT_MODE_CLIPBOARD))


func _fallback_to_clipboard_enabled() -> bool:
	return bool(ProjectSettings.get_setting(SETTING_FALLBACK_TO_CLIPBOARD, true))


func _neovim_executable() -> String:
	var executable := String(ProjectSettings.get_setting(SETTING_NEOVIM_EXECUTABLE, "nvr")).strip_edges()
	if executable.is_empty():
		return "nvr"

	return executable


func _neovim_server_address() -> String:
	var address := String(
		ProjectSettings.get_setting(SETTING_NEOVIM_SERVER_ADDRESS, _default_neovim_server_address())
	).strip_edges()
	if address.is_empty():
		return _default_neovim_server_address()

	return address


func _add_tool_menu_items() -> void:
	add_tool_menu_item(MENU_COPY_NODE_PATH, _copy_node_path)

	if _gdscript_enabled():
		add_tool_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference)
		add_tool_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference)
		add_tool_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var)

	if _csharp_enabled():
		add_tool_menu_item(MENU_COPY_CSHARP_GET_NODE, _copy_csharp_get_node_reference)
		add_tool_menu_item(MENU_COPY_CSHARP_PROPERTY, _copy_csharp_property_snippet)


func _remove_tool_menu_items() -> void:
	for menu_name in [
		MENU_COPY_NODE_PATH,
		MENU_COPY_DOLLAR_REFERENCE,
		MENU_COPY_GET_NODE,
		MENU_COPY_ONREADY_VAR,
		MENU_COPY_CSHARP_GET_NODE,
		MENU_COPY_CSHARP_PROPERTY,
	]:
		remove_tool_menu_item(menu_name)


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


func _copy_csharp_get_node_reference() -> void:
	_copy_for_selected_node(func(selected: Node) -> String:
		return _csharp_get_node_reference(selected)
	)


func _copy_csharp_property_snippet() -> void:
	_copy_for_selected_node(func(selected: Node) -> String:
		return _csharp_property_snippet(selected)
	)


func _copy_for_selected_node(renderer: Callable) -> void:
	var selected := _get_selected_node()
	if selected == null:
		return

	_deliver_text(renderer.call(selected))


func _copy_for_node(node: Node, renderer: Callable) -> void:
	if node == null:
		return

	_deliver_text(renderer.call(node))


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

	var normalized_path := _path_with_leading_slash(path)
	if _requires_quoted_dollar_path(normalized_path):
		return '$"%s"' % normalized_path

	return "$%s" % normalized_path


func _get_node_reference(node: Node) -> String:
	var path := _relative_node_path(node)
	if path == ".":
		return "self"

	return 'get_node("%s")' % _path_with_leading_slash(path)


func _onready_var_snippet(node: Node) -> String:
	var variable_name := _variable_name_for_node(node)
	var type_name := node.get_class()
	var reference := _dollar_reference(node)
	return "@onready var %s: %s = %s" % [variable_name, type_name, reference]


func _csharp_get_node_reference(node: Node) -> String:
	var path := _relative_node_path(node)
	if path == ".":
		return "this"

	return 'GetNode<%s>("%s")' % [node.get_class(), _path_with_leading_slash(path)]


func _path_with_leading_slash(path: String) -> String:
	if path.begins_with("/"):
		return path

	return "/" + path


func _requires_quoted_dollar_path(path: String) -> bool:
	for i in path.length():
		var ch := path.substr(i, 1)
		var is_alpha := ch >= "a" and ch <= "z" or ch >= "A" and ch <= "Z"
		var is_digit := ch >= "0" and ch <= "9"
		if is_alpha or is_digit or ch == "_" or ch == "/":
			continue

		return true

	return false


func _csharp_property_snippet(node: Node) -> String:
	var property_name := _property_name_for_node(node)
	var type_name := node.get_class()
	var reference := _csharp_get_node_reference(node)
	return "private %s %s => %s;" % [type_name, property_name, reference]


func _variable_name_for_node(node: Node) -> String:
	var base_name := String(node.name).to_snake_case()
	if base_name.is_empty():
		base_name = "node"

	if _starts_with_ascii_digit(base_name):
		base_name = "node_%s" % base_name

	return base_name


func _property_name_for_node(node: Node) -> String:
	var base_name := String(node.name).to_pascal_case()
	if base_name.is_empty():
		base_name = "Node"

	if _starts_with_ascii_digit(base_name):
		base_name = "Node%s" % base_name

	return base_name


func _starts_with_ascii_digit(value: String) -> bool:
	if value.is_empty():
		return false

	var code := value.unicode_at(0)
	return code >= 48 and code <= 57


func _default_neovim_server_address() -> String:
	if OS.get_name() == "Windows":
		return DEFAULT_WINDOWS_SERVER_ADDRESS

	return DEFAULT_UNIX_SERVER_ADDRESS


func _deliver_text(text: String) -> void:
	if _output_mode() == OUTPUT_MODE_NEOVIM:
		if _insert_into_neovim(text):
			return

		if not _fallback_to_clipboard_enabled():
			return

		push_warning("godotdev.nvim-node-copy: falling back to the clipboard")

	_copy_to_clipboard(text)


func _insert_into_neovim(text: String) -> bool:
	var temp_path := _write_insert_tempfile(text + "\n")
	if temp_path.is_empty():
		push_warning("godotdev.nvim-node-copy: failed to prepare snippet for Neovim insertion")
		return false

	var output: Array = []
	var command := _build_neovim_insert_command(temp_path)
	var exit_code := OS.execute(_neovim_executable(), [
		"--nostart",
		"--servername",
		_neovim_server_address(),
		"-c",
		command,
	], output, true)
	DirAccess.remove_absolute(temp_path)

	if exit_code != 0:
		push_warning(
			"godotdev.nvim-node-copy: failed to insert into Neovim server `%s` with `%s` (exit code %d)%s"
			% [_neovim_server_address(), _neovim_executable(), exit_code, _joined_output_suffix(output)]
		)
		return false

	print("godotdev.nvim-node-copy: inserted text into Neovim buffer")
	return true


func _build_neovim_insert_command(temp_path: String) -> String:
	var path_literal := _lua_long_bracket_literal(temp_path)
	return (
		"lua "
		+ "local text = table.concat(vim.fn.readfile("
		+ path_literal
		+ "), '\\n') .. '\\n'; "
		+ "local lines = vim.split(text, '\\n', { plain = true }); "
		+ "local line_count = #lines; "
		+ "local win = vim.api.nvim_get_current_win(); "
		+ "local buf = vim.api.nvim_win_get_buf(win); "
		+ "local cursor = vim.api.nvim_win_get_cursor(win); "
		+ "local row = cursor[1] - 1; "
		+ "local col = cursor[2]; "
		+ "vim.api.nvim_buf_set_text(buf, row, col, row, col, lines); "
		+ "local last_line = lines[line_count]; "
		+ "local target_col = (line_count == 1 and col or 0) + #last_line; "
		+ "vim.api.nvim_win_set_cursor(win, { row + line_count, target_col })"
	)


func _write_insert_tempfile(text: String) -> String:
	var base_dir := OS.get_user_data_dir().path_join("godotdev_nvim_node_copy")
	var make_dir_err := DirAccess.make_dir_recursive_absolute(base_dir)
	if make_dir_err != OK and make_dir_err != ERR_ALREADY_EXISTS:
		return ""

	var temp_path := base_dir.path_join("insert_%d.txt" % Time.get_ticks_usec())
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return ""

	file.store_string(text)
	file.close()
	return temp_path


func _lua_long_bracket_literal(text: String) -> String:
	var level := 0
	var closing := "]" + "=".repeat(level) + "]"
	while text.contains(closing):
		level += 1
		closing = "]" + "=".repeat(level) + "]"

	var opening := "[" + "=".repeat(level) + "["
	return opening + text + closing


func _joined_output_suffix(output: Array) -> String:
	if output.is_empty():
		return ""

	return ": %s" % "\n".join(PackedStringArray(output))


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

		if (_plugin as EditorPlugin)._gdscript_enabled():
			add_context_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference_context, MENU_ICON)
			add_context_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference_context, MENU_ICON)
			add_context_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var_context, MENU_ICON)

		if (_plugin as EditorPlugin)._csharp_enabled():
			add_context_menu_item(MENU_COPY_CSHARP_GET_NODE, _copy_csharp_get_node_reference_context, MENU_ICON)
			add_context_menu_item(MENU_COPY_CSHARP_PROPERTY, _copy_csharp_property_snippet_context, MENU_ICON)


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


	func _copy_csharp_get_node_reference_context(_selection: Array) -> void:
		var node: Node = (_plugin as EditorPlugin)._get_selected_node()
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._csharp_get_node_reference(selected)
		)


	func _copy_csharp_property_snippet_context(_selection: Array) -> void:
		var node: Node = (_plugin as EditorPlugin)._get_selected_node()
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._csharp_property_snippet(selected)
		)


class CanvasItemContextMenuPlugin extends EditorContextMenuPlugin:
	var _plugin: EditorPlugin


	func _init(plugin: EditorPlugin) -> void:
		_plugin = plugin


	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.is_empty():
			return

		add_context_menu_item(MENU_COPY_NODE_PATH, _copy_node_path_context, MENU_ICON)

		if (_plugin as EditorPlugin)._gdscript_enabled():
			add_context_menu_item(MENU_COPY_DOLLAR_REFERENCE, _copy_dollar_reference_context, MENU_ICON)
			add_context_menu_item(MENU_COPY_GET_NODE, _copy_get_node_reference_context, MENU_ICON)
			add_context_menu_item(MENU_COPY_ONREADY_VAR, _copy_onready_var_context, MENU_ICON)

		if (_plugin as EditorPlugin)._csharp_enabled():
			add_context_menu_item(MENU_COPY_CSHARP_GET_NODE, _copy_csharp_get_node_reference_context, MENU_ICON)
			add_context_menu_item(MENU_COPY_CSHARP_PROPERTY, _copy_csharp_property_snippet_context, MENU_ICON)


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


	func _copy_csharp_get_node_reference_context(selection: Array) -> void:
		var node: Node = _node_from_selection(selection)
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._csharp_get_node_reference(selected)
		)


	func _copy_csharp_property_snippet_context(selection: Array) -> void:
		var node: Node = _node_from_selection(selection)
		(_plugin as EditorPlugin)._copy_for_node(node, func(selected: Node) -> String:
			return (_plugin as EditorPlugin)._csharp_property_snippet(selected)
		)


	func _node_from_selection(selection: Array) -> Node:
		if selection.is_empty():
			return null

		if selection[0] is Node:
			return selection[0] as Node

		push_warning("godotdev.nvim-node-copy: 2D context menu selection did not resolve to a node")
		return null
