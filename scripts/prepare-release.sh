#!/usr/bin/env bash

set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "Usage: $0 <version> [--push]" >&2
  exit 1
fi

version="$1"
push_after="${2:-}"

case "$version" in
  [0-9]*.[0-9]*.[0-9]*)
    ;;
  *)
    echo "Version must look like 0.3.1" >&2
    exit 1
    ;;
esac

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree must be clean before preparing a release." >&2
  exit 1
fi

plugin_cfg="addons/godotdev_nvim_node_copy/plugin.cfg"
current_version="$(sed -n 's/^version="\(.*\)"$/\1/p' "$plugin_cfg")"

if [ "$current_version" = "$version" ]; then
  echo "plugin.cfg already has version $version" >&2
  exit 1
fi

perl -0pi -e 's/version="[^"]*"/version="'"$version"'"/' "$plugin_cfg"

git add "$plugin_cfg"
git commit -m "chore: release $version"
git tag "v$version"

if [ "$push_after" = "--push" ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  git push origin "$branch"
  git push origin "v$version"
fi

echo "Prepared release v$version"
echo "Committed plugin.cfg bump and created tag v$version"
if [ "$push_after" != "--push" ]; then
  echo "Next: git push origin $(git rev-parse --abbrev-ref HEAD) && git push origin v$version"
fi
