# Releasing

This repository uses the version in `addons/godotdev_nvim_node_copy/plugin.cfg`
as the release version that Godot users will see after installing from GitHub or
the Asset Library. The release workflow updates `plugin.cfg`, commits the bump to
the default branch, creates the tag, and publishes the release artifact.

## Release flow

1. Merge your release-ready changes into the default branch.
2. In GitHub, open `Actions` and run `Release Addon`.
3. Enter the release version, for example `0.3.3`.
4. Wait for the workflow to finish.
5. Verify the default branch contains the `plugin.cfg` bump commit.
6. Verify the GitHub release contains `godotdev_nvim_node_copy-0.3.3.zip`.

## What the workflow does

- updates `plugin.cfg`
- creates a release commit
- creates a `vX.Y.Z` tag
- pushes the default branch and tag
- uploads the packaged addon zip to the GitHub release

## Safety checks

- `Release Addon` rejects versions that do not look like `X.Y.Z`.
- `Release Addon` fails if the target tag already exists.
- `Validate Addon` checks semver formatting and the packaged addon layout on push
  and pull request.

## Example

Run `Release Addon` with version `0.3.3`.
