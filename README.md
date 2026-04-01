# godotdev.nvim-node-copy

`godotdev.nvim-node-copy` is a small Godot editor addon for users of [`godotdev.nvim`](https://github.com/Mathijs-Bakker/godotdev.nvim).

It adds copy actions for the currently selected node so you can paste useful references directly into Neovim without relying on drag-and-drop or custom IPC.

## Features

- Copy the selected node path relative to the current scene root
- Copy a `$Node/Child` reference
- Copy a `get_node("Node/Child")` expression
- Copy a typed `@onready var` snippet
- Works from the current editor selection
- Clipboard-only workflow; no Neovim-side receiver required

## Install

Copy the `addons/godotdev_nvim_node_copy` folder into your Godot project:

```text
res://addons/godotdev_nvim_node_copy
```

Then enable the plugin in:

`Project > Project Settings > Plugins`

## Usage

Select a node in the Scene dock, then use one of these menu items:

- `Project > Tools > godotdev.nvim: Copy Node Path`
- `Project > Tools > godotdev.nvim: Copy $ Reference`
- `Project > Tools > godotdev.nvim: Copy get_node()`
- `Project > Tools > godotdev.nvim: Copy @onready Var`

The generated text is copied to your clipboard. Paste it in Neovim where you want it.

## Example Output

For a selected `Player` node:

```gdscript
Player
```

```gdscript
$Player
```

```gdscript
get_node("Player")
```

```gdscript
@onready var player: CharacterBody2D = $Player
```

## Notes

- The addon uses the selected node relative to the currently edited scene root.
- If the selected node is the scene root itself, the generated snippets use `self` where appropriate.
- The addon currently targets GDScript snippets first.

## Roadmap

- Support `%UniqueNode` when appropriate
- Add C# snippet variants
- Let users choose snippet style in plugin settings
- Add context-menu integration in the Scene dock
