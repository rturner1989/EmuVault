#!/bin/bash
set -e

# Auto-increments the patch version unless a version is explicitly provided.
# Usage:
#   ./scripts/deploy.sh          # 1.0.0 → 1.0.1
#   ./scripts/deploy.sh 1.2.0   # explicit version

CURRENT=$(cat VERSION | tr -d '[:space:]')

if [ -n "${1:-}" ]; then
  VERSION="$1"
else
  # Auto-increment patch
  MAJOR=$(echo "$CURRENT" | cut -d. -f1)
  MINOR=$(echo "$CURRENT" | cut -d. -f2)
  PATCH=$(echo "$CURRENT" | cut -d. -f3)
  VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
fi

TAG="v$VERSION"

# Ensure working directory is clean
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: uncommitted changes present. Commit or stash them first."
  exit 1
fi

# Ensure we're on main
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
  echo "Error: must be on main branch (currently on $BRANCH)."
  exit 1
fi

# Ensure tag doesn't already exist
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Error: tag $TAG already exists."
  exit 1
fi

echo "Releasing $CURRENT → $VERSION..."

echo "$VERSION" > VERSION
git add VERSION
git commit -m "Release $TAG"
git tag "$TAG"
git push origin main
git push origin "$TAG"

echo ""
echo "Tag $TAG pushed — GitHub Actions is building the Docker image."
echo "Follow progress: https://github.com/rturner1989/emuvault/actions"
echo ""
echo "Once the build completes (~5 min), update TrueNAS Scale:"
echo "  Apps > emuvault > Stop → Start  (re-pulls :latest automatically)"
