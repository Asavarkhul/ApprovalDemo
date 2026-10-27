#!/usr/bin/env bash
# Downloads third-party skills at pinned commits, with their license.
# Bump a commit here, rerun, and review the diff.
set -euo pipefail

readonly SKILLS_DIR=".claude/skills"

# owner/repo|commit|path in repo
readonly SOURCES=(
  "AvdLee/SwiftUI-Agent-Skill|204dba7c67256a8b707ee3fbc5759a824191974f|skills/swiftui-expert-skill"
  "AvdLee/Swift-Concurrency-Agent-Skill|d5770817d2622e1585b1f7eaebc791a9cb0959c8|skills/swift-concurrency"
  "AvdLee/Swift-Testing-Agent-Skill|798e9b1a2bcac164d4f0c781908199e754f0bab6|swift-testing-expert"
)

fetch() {
  local repo="$1" sha="$2" path="$3"
  local name tmp root
  name=$(basename "$path")
  tmp=$(mktemp -d)

  curl -fsSL "https://github.com/$repo/archive/$sha.tar.gz" | tar -xz -C "$tmp"
  root="$tmp/${repo#*/}-$sha"

  rm -rf "${SKILLS_DIR:?}/$name"
  cp -R "$root/$path" "$SKILLS_DIR/$name"
  cp "$root/LICENSE" "$SKILLS_DIR/$name/LICENSE"
  echo "$repo@$sha" > "$SKILLS_DIR/$name/SOURCE"

  rm -rf "$tmp"
}

cd "$(dirname "$0")/.."

for source in "${SOURCES[@]}"; do
  IFS='|' read -r repo sha path <<< "$source"
  fetch "$repo" "$sha" "$path"
done
