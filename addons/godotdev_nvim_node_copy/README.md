# godotdev.nvim-node-copy

`godotdev.nvim-node-copy` is a Godot editor addon for users of
[`godotdev.nvim`](https://github.com/Mathijs-Bakker/godotdev.nvim).

It adds copy actions for the currently selected node so you can paste useful
references directly into Neovim without relying on drag-and-drop or custom IPC.

## Install

Place this folder in your Godot project at:

```text
res://addons/godotdev_nvim_node_copy
```

Then enable the plugin in:

`Project > Project Settings > Plugins`

## Usage

Select a node in the Scene dock, then use either:

- the Scene Tree right-click menu
- the 2D editor right-click menu
- `Project > Tools`

Available actions:

- `Project > Tools > godotdev.nvim: Copy Node Path`
- `Project > Tools > godotdev.nvim: Copy $ Reference`
- `Project > Tools > godotdev.nvim: Copy get_node()`
- `Project > Tools > godotdev.nvim: Copy @onready Var`
- `Project > Tools > godotdev.nvim: Copy C# GetNode<T>()`
- `Project > Tools > godotdev.nvim: Copy C# Property`

## Configuration

Project Settings keys:

- `godotdev_nvim_node_copy/enable_gdscript`
- `godotdev_nvim_node_copy/enable_csharp`

`Copy Node Path` remains available regardless of language selection.

## Repository

Project page and full documentation:

https://github.com/Mathijs-Bakker/godotdev.nvim-node-copy
