#!/usr/bin/env bash
# cl — CLI tool for managing genai_components package inside this Flutter project
#
# Usage:
#   ./cl init
#   ./cl dev
#   ./cl prod
#   ./cl status
#   ./cl pull [branch]
#   ./cl branch <name> [start-branch]
#   ./cl checkout <branch>
#   ./cl push ["message"]
#   ./cl promote [target-branch]
#   ./cl clean [--force]
#   ./cl git <git-args...>
#   ./cl doctor
#   ./cl version <major|minor|patch>
#   ./cl publish [--yes]
#   ./cl release <major|minor|patch>
#
# Design goals:
# - one-window workflow in Android Studio
# - local clone visible inside the project tree
# - safe detach from local override
# - no accidental deletion of uncommitted work
# - no risky auto-merge during push

set -euo pipefail

PACKAGE_NAME="genai_components"
PACKAGE_DIR="./genai_components"
REPO_URL="https://github.com/GenerazioneAI-SRL/genai_components.git"
OVERRIDE_FILE="pubspec_overrides.yaml"
PUBSPEC="pubspec.yaml"
GITIGNORE=".gitignore"

# Safe defaults
BASE_BRANCH="stable"   # branch used in pubspec git dependency
DEV_BRANCH="main"      # default branch for development work

# Markers used to manage only the override created by this script
MARKER_BEGIN="# >>> cl managed override >>>"
MARKER_END="# <<< cl managed override <<<"

say()   { printf '%s\n' "$*"; }
info()  { say "ℹ️  $*"; }
ok()    { say "✅ $*"; }
warn()  { say "⚠️  $*"; }
die()   { say "❌ $*" >&2; exit 1; }

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_flutter_project() {
  [ -f "$PUBSPEC" ] || die "No $PUBSPEC found. Run this from the Flutter project root."
}

ensure_git() {
  have_cmd git || die "git not found in PATH."
}

ensure_flutter() {
  have_cmd flutter || die "flutter not found in PATH."
}

ensure_python() {
  have_cmd python3 || die "python3 not found in PATH."
}

ensure_dart() {
  have_cmd dart || die "dart not found in PATH."
}

package_version() {
  grep -E '^version:' "$PACKAGE_DIR/pubspec.yaml" | sed 's/version:[[:space:]]*//'
}

package_exists() {
  [ -d "$PACKAGE_DIR/.git" ]
}

package_git() {
  git -C "$PACKAGE_DIR" "$@"
}

current_package_branch() {
  package_git rev-parse --abbrev-ref HEAD
}

package_is_dirty() {
  ! package_git diff --quiet --ignore-submodules -- || \
  ! package_git diff --cached --quiet --ignore-submodules --
}

override_is_managed() {
  [ -f "$OVERRIDE_FILE" ] && grep -Fq "$MARKER_BEGIN" "$OVERRIDE_FILE"
}

guard_override_write() {
  if [ -f "$OVERRIDE_FILE" ] && ! override_is_managed; then
    die "$OVERRIDE_FILE already exists and was not created by this script. Refusing to overwrite it."
  fi
}

write_override() {
  guard_override_write
  cat > "$OVERRIDE_FILE" <<EOF
$MARKER_BEGIN
dependency_overrides:
  $PACKAGE_NAME:
    path: $PACKAGE_DIR
$MARKER_END
EOF
}

remove_override() {
  if [ ! -f "$OVERRIDE_FILE" ]; then
    info "No $OVERRIDE_FILE found."
    return 0
  fi

  if ! override_is_managed; then
    die "$OVERRIDE_FILE exists but is not managed by this script. Refusing to delete it."
  fi

  rm -f "$OVERRIDE_FILE"
}

ensure_ignore_line() {
  local line="$1"
  local header="$2"

  if [ ! -f "$GITIGNORE" ]; then
    {
      printf '%s\n' "$header"
      printf '%s\n' "$line"
    } > "$GITIGNORE"
    return 0
  fi

  if ! grep -Fqx "$line" "$GITIGNORE"; then
    if ! grep -Fqx "$header" "$GITIGNORE"; then
      printf '\n%s\n' "$header" >> "$GITIGNORE"
    fi
    printf '%s\n' "$line" >> "$GITIGNORE"
  fi
}

ensure_clone() {
  ensure_git

  if package_exists; then
    info "$PACKAGE_DIR already exists — using existing clone."
    return 0
  fi

  if [ -e "$PACKAGE_DIR" ] && [ ! -d "$PACKAGE_DIR/.git" ]; then
    die "$PACKAGE_DIR exists but is not a git clone. Remove it or convert it into a proper repo."
  fi

  info "Cloning $PACKAGE_NAME into project..."
  git clone "$REPO_URL" "$PACKAGE_DIR"
}

ensure_pubspec_dependency() {
  ensure_python

  python3 - "$PUBSPEC" "$PACKAGE_NAME" "$REPO_URL" "$BASE_BRANCH" <<'PY'
import re
import sys
from pathlib import Path

pubspec = Path(sys.argv[1])
package = sys.argv[2]
repo_url = sys.argv[3]
base_branch = sys.argv[4]

content = pubspec.read_text()

# Only skip if the package key already exists as a dependency key with standard indentation.
if re.search(rf'(?m)^  {re.escape(package)}\s*:', content):
    print("SKIP")
    raise SystemExit(0)

block = f"""  {package}:
    git:
      url: {repo_url}
      ref: {base_branch}
"""

match = re.search(r'(?m)^dependencies:\s*$', content)
if not match:
    print("ERROR: dependencies section not found", file=sys.stderr)
    raise SystemExit(2)

insert_at = match.end()
new_content = content[:insert_at] + "\n" + block + content[insert_at:]
pubspec.write_text(new_content)
print("ADDED")
PY
}

run_pub_get() {
  ensure_flutter
  flutter pub get
}

cmd_init() {
  ensure_flutter_project
  ensure_git

  info "Initializing $PACKAGE_NAME in this project..."

  local result
  if result="$(ensure_pubspec_dependency 2>&1)"; then
    if [ "$result" = "ADDED" ]; then
      ok "Added $PACKAGE_NAME to $PUBSPEC."
    else
      info "$PACKAGE_NAME already present in $PUBSPEC — skipping dependency insert."
    fi
  else
    die "Failed to update $PUBSPEC: $result"
  fi

  ensure_ignore_line "$OVERRIDE_FILE" "# CL Components local development"
  ensure_ignore_line "$PACKAGE_DIR/" "# CL Components local development"
  ok "Updated $GITIGNORE."

  run_pub_get

  say ""
  ok "Setup complete."
  say "   ./cl dev                    — clone & link local package"
  say "   ./cl prod                   — remove local override"
  say "   ./cl status                 — show current mode"
  say "   ./cl branch fix/my-change   — create/switch branch"
  say "   ./cl push                   — commit all changes + push"
  say "   ./cl promote                — merge current branch into $BASE_BRANCH"
  say "   ./cl clean                  — delete local clone if safe"
}

cmd_dev() {
  ensure_flutter_project
  ensure_clone
  write_override
  run_pub_get
  ok "Local development mode active."
  say "   Edit $PACKAGE_DIR/ directly in this project."
}

cmd_prod() {
  ensure_flutter_project
  remove_override

  if [ -d "$PACKAGE_DIR" ]; then
    if package_exists && package_is_dirty; then
      die "Local package has uncommitted changes. Commit or stash them first, or use './cl clean --force' to discard."
    fi
    rm -rf "$PACKAGE_DIR"
    info "Removed local clone at $PACKAGE_DIR."
  fi

  run_pub_get
  ok "Production mode active — using GitHub dependency."
}

cmd_status() {
  say "📊 $PACKAGE_NAME status:"
  say ""

  if [ -f "$OVERRIDE_FILE" ]; then
    if override_is_managed; then
      say "   Mode: 🔗 DEV (local override active)"
    else
      say "   Mode: ❓ CUSTOM ($OVERRIDE_FILE exists but is not managed by this script)"
    fi
  else
    say "   Mode: 🔒 PROD (GitHub)"
  fi

  if package_exists; then
    say "   Local: $PACKAGE_DIR (inside project)"
    say "   Branch: $(current_package_branch 2>/dev/null || echo unknown)"
    say "   Remote: $(package_git remote get-url origin 2>/dev/null || echo unknown)"
    say "   Last commit: $(package_git log --oneline -1 2>/dev/null || echo none)"
    if package_is_dirty; then
      say "   Working tree: DIRTY"
    else
      say "   Working tree: clean"
    fi
  else
    say "   Local: not cloned (run './cl dev' to clone)"
  fi
}

cmd_pull() {
  local branch="${1:-}"

  ensure_clone

  if package_is_dirty; then
    die "Package repo has uncommitted changes. Commit or stash them before pulling."
  fi

  if [ -z "$branch" ]; then
    branch="$(current_package_branch || true)"
    if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
      branch="$BASE_BRANCH"
    fi
  fi

  info "Fetching package repo..."
  package_git fetch --all --prune

  if package_git show-ref --verify --quiet "refs/heads/$branch"; then
    package_git checkout "$branch" >/dev/null 2>&1
  elif package_git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    package_git checkout -b "$branch" "origin/$branch" >/dev/null 2>&1
  else
    die "Branch '$branch' does not exist locally or on origin."
  fi

  if package_git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    package_git pull --rebase origin "$branch"
  else
    warn "No remote origin/$branch found. Nothing to pull."
  fi

  run_pub_get
  ok "Updated local package on branch '$branch'."
}

cmd_branch() {
  local new_branch="${1:-}"
  local start_branch="${2:-$DEV_BRANCH}"

  [ -n "$new_branch" ] || die "Usage: ./cl branch <new-branch> [start-branch]"
  ensure_clone

  if package_is_dirty; then
    die "Package repo has uncommitted changes. Commit or stash them before switching branch."
  fi

  package_git fetch --all --prune

  if package_git show-ref --verify --quiet "refs/heads/$new_branch"; then
    package_git checkout "$new_branch"
    ok "Checked out existing local branch '$new_branch'."
    return 0
  fi

  if package_git show-ref --verify --quiet "refs/remotes/origin/$new_branch"; then
    package_git checkout -b "$new_branch" "origin/$new_branch"
    ok "Checked out existing remote branch '$new_branch'."
    return 0
  fi

  if package_git show_ref --verify --quiet "refs/remotes/origin/$start_branch"; then
    package_git checkout -b "$new_branch" "origin/$start_branch"
  elif package_git show_ref --verify --quiet "refs/heads/$start_branch"; then
    package_git checkout -b "$new_branch" "$start_branch"
  else
    die "Start branch '$start_branch' not found locally or on origin."
  fi

  ok "Created branch '$new_branch' from '$start_branch'."
}

cmd_checkout() {
  local branch="${1:-}"
  [ -n "$branch" ] || die "Usage: ./cl checkout <branch>"
  ensure_clone

  if package_is_dirty; then
    die "Package repo has uncommitted changes. Commit or stash them before switching branch."
  fi

  package_git fetch --all --prune

  if package_git show-ref --verify --quiet "refs/heads/$branch"; then
    package_git checkout "$branch"
  elif package_git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    package_git checkout -b "$branch" "origin/$branch"
  else
    die "Branch '$branch' not found locally or on origin."
  fi

  ok "Checked out '$branch'."
}

cmd_push() {
  local msg="${1:-commit}"
  package_exists || die "Package repo not found at $PACKAGE_DIR. Run './cl dev' first."

  local branch
  branch="$(current_package_branch)"
  [ "$branch" != "HEAD" ] || die "Detached HEAD detected. Checkout a branch before pushing."

  if package_is_dirty; then
    package_git add -A
    package_git commit -m "$msg"
    ok "Commit created on $branch."
  else
    info "Nothing to commit."
  fi

  if package_git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
    package_git push
  else
    package_git push -u origin "$branch"
  fi

  ok "Pushed branch '$branch'."
}

cmd_promote() {
  local target="${1:-$BASE_BRANCH}"
  package_exists || die "Package repo not found at $PACKAGE_DIR. Run './cl dev' first."

  if package_is_dirty; then
    die "Package repo has uncommitted changes. Commit or stash them before promoting."
  fi

  local source
  source="$(current_package_branch)"
  [ "$source" != "HEAD" ] || die "Detached HEAD detected. Checkout a branch first."
  [ "$source" != "$target" ] || die "Already on target branch '$target'."

  package_git fetch --all --prune

  if package_git show-ref --verify --quiet "refs/heads/$target"; then
    package_git checkout "$target"
  elif package_git show-ref --verify --quiet "refs/remotes/origin/$target"; then
    package_git checkout -b "$target" "origin/$target"
  else
    die "Target branch '$target' not found locally or on origin."
  fi

  if package_git show-ref --verify --quiet "refs/remotes/origin/$target"; then
    package_git pull --rebase origin "$target"
  fi

  package_git merge --no-ff --no-edit "$source"
  package_git push origin "$target"
  package_git checkout "$source"

  ok "Merged '$source' into '$target' and pushed it."
}

cmd_clean() {
  local force="${1:-}"

  if [ -f "$OVERRIDE_FILE" ]; then
    die "Local override is still active. Run './cl prod' first."
  fi

  if [ ! -d "$PACKAGE_DIR" ]; then
    info "Nothing to clean."
    return 0
  fi

  if package_exists && package_is_dirty && [ "$force" != "--force" ]; then
    die "Local package has uncommitted changes. Use './cl clean --force' only if you really want to delete them."
  fi

  rm -rf "$PACKAGE_DIR"
  ok "Removed local clone at $PACKAGE_DIR."
}

cmd_version() {
  local bump="${1:-}"
  [ -n "$bump" ] || die "Usage: ./cl version <major|minor|patch>"
  [[ "$bump" =~ ^(major|minor|patch)$ ]] || die "Invalid bump type '$bump'. Use major, minor, or patch."

  package_exists || die "Package repo not found at $PACKAGE_DIR. Run './cl dev' first."

  if package_is_dirty; then
    die "Package repo has uncommitted changes. Commit or stash them before bumping version."
  fi

  ensure_python

  local new_version
  new_version="$(python3 - "$PACKAGE_DIR/pubspec.yaml" "$bump" <<'PY'
import re, sys
from pathlib import Path

pubspec = Path(sys.argv[1])
bump = sys.argv[2]
content = pubspec.read_text()

match = re.search(r'^version:\s*(\d+)\.(\d+)\.(\d+)', content, re.MULTILINE)
if not match:
    print("ERROR", file=sys.stderr)
    raise SystemExit(1)

major, minor, patch = int(match.group(1)), int(match.group(2)), int(match.group(3))

if bump == "major":
    major += 1; minor = 0; patch = 0
elif bump == "minor":
    minor += 1; patch = 0
elif bump == "patch":
    patch += 1

new_ver = f"{major}.{minor}.{patch}"
new_content = re.sub(r'^(version:\s*)\d+\.\d+\.\d+', rf'\g<1>{new_ver}', content, count=1, flags=re.MULTILINE)
pubspec.write_text(new_content)
print(new_ver)
PY
  )" || die "Failed to bump version."

  # Auto-generate CHANGELOG entry from diff
  local changelog="$PACKAGE_DIR/CHANGELOG.md"
  local prev_tag
  prev_tag="$(package_git describe --tags --abbrev=0 2>/dev/null || echo "")"

  local diff_stat
  if [ -n "$prev_tag" ]; then
    diff_stat="$(package_git diff "${prev_tag}..HEAD" --stat --stat-width=200 2>/dev/null || echo "")"
  else
    diff_stat="$(package_git diff HEAD~1..HEAD --stat --stat-width=200 2>/dev/null || echo "")"
  fi

  ensure_python

  local changelog_entry
  changelog_entry="$(python3 - "$diff_stat" <<'PY'
import sys, re
from collections import defaultdict

stat = sys.argv[1]
if not stat.strip():
    print("- Maintenance and minor improvements")
    raise SystemExit(0)

# Parse file changes from diff --stat
files = []
for line in stat.strip().split("\n"):
    m = re.match(r'^\s*(.+?)\s+\|\s+(\d+)', line)
    if m:
        files.append(m.group(1).strip())

if not files:
    print("- Maintenance and minor improvements")
    raise SystemExit(0)

# Categorize by directory/type
categories = defaultdict(list)
for f in files:
    parts = f.split("/")
    name = parts[-1].replace(".dart", "").replace("_", " ").replace(".", " ")

    if "widget" in f or f.startswith("lib/widgets/"):
        widget = parts[-1].replace(".dart", "").replace(".widget", "")
        # Extract CL-prefixed class names
        cl = re.findall(r'cl_(\w+)', widget)
        label = "CL" + "".join(w.capitalize() for w in cl) if cl else widget.replace("_", " ").title()
        categories["Widgets"].append(label)
    elif "chart" in f:
        categories["Charts"].append(name.title())
    elif "layout" in f or f.startswith("lib/layout/"):
        categories["Layout"].append(name.title())
    elif "router" in f or "modular" in f:
        categories["Router"].append(name.title())
    elif "provider" in f or f.startswith("lib/providers/"):
        categories["Providers"].append(name.title())
    elif "model" in f or f.startswith("lib/core_models/") or f.startswith("lib/models/"):
        categories["Models"].append(name.title())
    elif "api" in f:
        categories["API"].append(name.title())
    elif "theme" in f:
        categories["Theme"].append(name.title())
    elif "survey" in f:
        categories["Survey"].append(name.title())
    elif "pubspec" in f or "changelog" in f or "readme" in f or "license" in f:
        categories["Package"].append(name.title())
    elif "example" in f:
        categories["Example"].append(name.title())
    elif "test" in f:
        categories["Tests"].append(name.title())
    else:
        categories["Core"].append(name.title())

# Build bullet points
bullets = []
order = ["Widgets", "Charts", "Layout", "Router", "API", "Theme", "Survey",
         "Providers", "Models", "Core", "Package", "Example", "Tests"]
for cat in order:
    items = categories.get(cat)
    if not items:
        continue
    unique = list(dict.fromkeys(items))  # dedupe preserving order
    if len(unique) <= 3:
        bullets.append(f"- **{cat}:** Updated {', '.join(unique)}")
    else:
        bullets.append(f"- **{cat}:** Updated {len(unique)} components")

if not bullets:
    bullets.append("- Maintenance and minor improvements")

# Cap at 10 bullets
print("\n".join(bullets[:10]))
PY
  )" || changelog_entry="- Maintenance and minor improvements"

  info "Generated changelog from diff."

  # Build new entry
  local new_entry
  new_entry="## $new_version"$'\n\n'"$changelog_entry"$'\n'

  if [ -f "$changelog" ]; then
    # Remove existing "## Unreleased" section (header + blank lines until next ##)
    local cleaned
    cleaned="$(python3 - "$changelog" "$new_entry" <<'PY'
import sys
from pathlib import Path

changelog = Path(sys.argv[1])
new_entry = sys.argv[2]
content = changelog.read_text()
lines = content.split("\n")

result = []
skip = False
inserted = False
for line in lines:
    if line.strip() == "## Unreleased":
        skip = True
        continue
    if skip and (line.startswith("## ") or (line.startswith("- ") and not inserted)):
        skip = False
    if skip and not line.strip():
        continue
    if not inserted and line.startswith("## ") and line.strip() != "## Unreleased":
        result.append(new_entry)
        result.append("")
        inserted = True
    result.append(line)

# If no other ## found, insert after header
if not inserted:
    final = []
    for i, line in enumerate(result):
        final.append(line)
        if i == 0 and line.startswith("# "):
            final.append("")
            final.append(new_entry)
    result = final

print("\n".join(result))
PY
    )"
    printf '%s\n' "$cleaned" > "$changelog"
  else
    printf '# Changelog\n\n%s\n' "$new_entry" > "$changelog"
  fi

  ok "CHANGELOG.md updated for v$new_version."

  package_git add pubspec.yaml CHANGELOG.md
  package_git commit -m "chore: bump version to $new_version"
  ok "Version bumped to $new_version."
}

cmd_publish() {
  local skip_confirm=false

  for arg in "$@"; do
    case "$arg" in
      --yes|-y) skip_confirm=true ;;
      *) die "Unknown flag '$arg'. Usage: ./cl publish [--yes]" ;;
    esac
  done

  package_exists || die "Package repo not found at $PACKAGE_DIR. Run './cl dev' first."
  ensure_flutter

  if package_is_dirty; then
    die "Package repo has uncommitted changes. Commit or stash them before publishing."
  fi

  local version
  version="$(package_version)"
  [ -n "$version" ] || die "Could not read version from $PACKAGE_DIR/pubspec.yaml."

  local branch
  branch="$(current_package_branch)"

  say ""
  say "📦 Publishing $PACKAGE_NAME v$version"
  say "   Branch: $branch"
  say ""

  info "Running dry-run..."
  if ! (cd "$PACKAGE_DIR" && flutter pub publish --dry-run); then
    die "Dry-run failed. Fix the issues above before publishing."
  fi

  say ""

  if [ "$skip_confirm" = false ]; then
    read -rp "🚀 Publish v$version to pub.dev? [y/N] " answer
    case "$answer" in
      [yY]|[yY][eE][sS]) ;;
      *) die "Publish aborted." ;;
    esac
  fi

  info "Publishing to pub.dev..."
  (cd "$PACKAGE_DIR" && flutter pub publish --force)

  # Tag and push
  local tag="v$version"
  if package_git rev-parse "$tag" >/dev/null 2>&1; then
    warn "Tag '$tag' already exists — skipping tag creation."
  else
    package_git tag -a "$tag" -m "Release $tag"
    package_git push origin "$tag"
    ok "Created and pushed tag '$tag'."
  fi

  ok "Published $PACKAGE_NAME v$version to pub.dev."
}

cmd_release() {
  local bump="${1:-}"
  [ -n "$bump" ] || die "Usage: ./cl release <major|minor|patch>"
  [[ "$bump" =~ ^(major|minor|patch)$ ]] || die "Invalid bump type '$bump'. Use major, minor, or patch."

  package_exists || die "Package repo not found at $PACKAGE_DIR. Run './cl dev' first."

  # Auto-commit pending changes (e.g. CHANGELOG.md written by AI assistant)
  if package_is_dirty; then
    info "Committing pending changes..."
    package_git add -A
    package_git commit -m "chore: pre-release updates"
  fi

  say ""
  say "🚀 Release workflow: version → push → promote → publish"
  say ""

  # 1. Bump version
  cmd_version "$bump"

  # 2. Push current branch
  cmd_push

  # 3. Promote to stable
  local branch
  branch="$(current_package_branch)"
  if [ "$branch" != "$BASE_BRANCH" ]; then
    cmd_promote "$BASE_BRANCH"
  else
    info "Already on $BASE_BRANCH — skipping promote."
  fi

  # 4. Publish (auto-confirm)
  cmd_publish --yes

  local version
  version="$(package_version)"
  say ""
  ok "🎉 Release v$version complete!"
}

cmd_git() {
  package_exists || die "Package repo not found at $PACKAGE_DIR. Run './cl dev' first."
  [ "$#" -gt 0 ] || die "Usage: ./cl git <git-args...>"
  package_git "$@"
}

cmd_doctor() {
  ensure_flutter_project
  ensure_git
  ensure_flutter

  say "🩺 Doctor"
  say "   Flutter project: OK"
  say "   git: $(command -v git)"
  say "   flutter: $(command -v flutter)"
  if have_cmd python3; then
    say "   python3: $(command -v python3)"
  else
    say "   python3: missing"
  fi
  say "   pubspec: $PUBSPEC"
  say "   override: $OVERRIDE_FILE"
  say "   package dir: $PACKAGE_DIR"

  if package_exists; then
    say "   package repo: OK"
    say "   package branch: $(current_package_branch || echo unknown)"
  else
    say "   package repo: not cloned"
  fi

  if [ -f "$OVERRIDE_FILE" ]; then
    if override_is_managed; then
      say "   override owner: this script"
    else
      say "   override owner: external/manual"
    fi
  else
    say "   override owner: none"
  fi
}

usage() {
  say "cl — Manage $PACKAGE_NAME"
  say ""
  say "Usage: ./cl <command>"
  say ""
  say "Commands:"
  say "  init                    Setup dependency and .gitignore"
  say "  dev                     Clone & link local package inside project"
  say "  prod                    Remove local override and use non-local dependency"
  say "  status                  Show current mode and package info"
  say "  doctor                  Run health checks"
  say "  pull [branch]           Pull latest for the package branch"
  say "  branch <name> [start]   Create/switch package branch"
  say "  checkout <branch>       Checkout package branch"
  say "  push [\"msg\"]            Commit all changes + push (default msg: \"commit\")"
  say "  promote [target]        Merge current branch into target (default: $BASE_BRANCH)"
  say "  clean [--force]         Delete local clone (requires prod mode)"
  say "  git <git-args...>       Pass through any git command to package repo"
  say ""
  say "Publishing:"
  say "  version <major|minor|patch>  Bump package version in pubspec.yaml"
  say "  publish [--yes]              Publish package to pub.dev"
  say "  release <major|minor|patch>  Version + push + promote + publish (full flow)"
}

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    init) cmd_init "$@" ;;
    dev) cmd_dev "$@" ;;
    prod) cmd_prod "$@" ;;
    status) cmd_status ;;
    doctor) cmd_doctor ;;
    pull) cmd_pull "$@" ;;
    branch) cmd_branch "$@" ;;
    checkout) cmd_checkout "$@" ;;
    checkout) cmd_checkout "$@" ;;
    push) cmd_push "$@" ;;
    promote) cmd_promote "$@" ;;
    clean) cmd_clean "$@" ;;
    version) cmd_version "$@" ;;
    publish) cmd_publish "$@" ;;
    release) cmd_release "$@" ;;
    git) cmd_git "$@" ;;
    ""|-h|--help|help) usage ;;
    *)
      die "Unknown command '$cmd'. Run './cl --help' for usage."
      ;;
  esac
}

main "$@"
