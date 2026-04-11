# godotdev.nvim-node-copy

`godotdev.nvim-node-copy` is a Godot editor addon for users of
[`godotdev.nvim`](https://github.com/Mathijs-Bakker/godotdev.nvim).

It adds node-reference actions for the currently selected node and can either
copy the generated text to the clipboard or insert it directly into the active
Neovim buffer.

## Install

### From AssetLib in the Godot editor

1. Open your project in Godot.
2. Go to the `AssetLib` tab.
3. Search for `godotdev.nvim-node-copy`.
4. Open the asset page and click `Download`.
5. Keep the install destination as your project root so Godot imports the
   addon into `res://addons/godotdev_nvim_node_copy`.
6. After import, go to `Project > Project Settings > Plugins` and enable
   `godotdev.nvim-node-copy`.

### Manual install

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
- `godotdev_nvim_node_copy/output/mode`
- `godotdev_nvim_node_copy/output/neovim_executable`
- `godotdev_nvim_node_copy/output/neovim_server_address`
- `godotdev_nvim_node_copy/output/fallback_to_clipboard`

`Copy Node Path` remains available regardless of language selection.

Output settings:
- `godotdev_nvim_node_copy/output/mode`: `clipboard` or `neovim_remote`
- `godotdev_nvim_node_copy/output/neovim_executable`: the executable used for remote insertion, default `nvim`
- `godotdev_nvim_node_copy/output/neovim_server_address`: the Neovim server address to target
- `godotdev_nvim_node_copy/output/fallback_to_clipboard`: fall back to the clipboard if remote insertion fails

To use direct insertion, start the Neovim editor server from `godotdev.nvim`
and set `godotdev_nvim_node_copy/output/mode` to `neovim_remote`.

## Repository

Project page and full documentation:

https://github.com/Mathijs-Bakker/godotdev.nvim-node-copy
