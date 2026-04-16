# Releasing

This repository uses the version in `addons/godotdev_nvim_node_copy/plugin.cfg`
as the release version that Godot users will see after installing from GitHub or
the Asset Library.

## Release flow

1. Make sure your working tree is clean.
2. Run `./scripts/prepare-release.sh 0.3.1` or `./scripts/prepare-release.sh 0.3.1 --push`.
3. If you did not use `--push`, push the branch and the tag:
   - `git push origin <branch>`
   - `git push origin v0.3.1`
4. Wait for GitHub Actions to run `Package Release`.
5. Verify the GitHub release contains `godotdev_nvim_node_copy-0.3.1.zip`.

## What the script does

- updates `plugin.cfg`
- creates a release commit
- creates a `vX.Y.Z` tag
- optionally pushes the branch and tag

## Safety checks

- `scripts/prepare-release.sh` refuses to run with a dirty working tree.
- `Package Release` fails if `plugin.cfg` does not match the tag version.
- `Validate Addon` checks semver formatting and the packaged addon layout on push
  and pull request.

## Example

```bash
./scripts/prepare-release.sh 0.3.1 --push
```

