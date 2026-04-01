# godotdev.nvim-node-copy

godotdev.nvim-node-copy is a small Godot editor addon that helps when using godotdev.nvim as your external editor.

It adds simple copy actions for selected nodes so you can paste useful references directly into Neovim without relying on drag-and-drop or custom IPC.

The addon is designed to keep the workflow explicit and safe:
select a node in Godot, copy the reference you want, then paste it at the cursor in Neovim.

## Initial Feature List

- Copy node path as Node/Child
- Copy scene path as $Node/Child
- Copy get_node("Node/Child")
- Copy typed @onready var snippet
- Copy inferred variable name from node name
- Work from the selected node in the SceneTree
- GDScript-first output
- No Neovim-side receiver required
- Clipboard-based workflow only

## Good MVP Scope

Start with 3 actions:

- Copy Node Path
- Copy $Node Reference
- Copy @onready Var

Example output:

$Player

get_node("Player")

@onready var player: CharacterBody2D = $Player

Nice Follow-up Features

- Support relative path vs absolute-from-scene-root path
- Support %UniqueNode when applicable
- Handle name sanitization for variable names
- Add C# snippet variants later
- Let users choose snippet style in addon settings


  - a concise README.md
  - the addon folder structure
  - the initial Godot plugin command names
