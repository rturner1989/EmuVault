#!/bin/bash
set -e

# Auto-increments the patch version unless a version is explicitly provided.
# Uses GitHub API to bump VERSION on main without switching branches.
#
# Usage:
#   ./scripts/deploy.sh          # 1.0.0 → 1.0.1
#   ./scripts/deploy.sh 1.2.0   # explicit version

CURRENT=$(cat VERSION | tr -d '[:space:]')

if [ -n "${1:-}" ]; then
  VERSION="$1"
else
  MAJOR=$(echo "$CURRENT" | cut -d. -f1)
  MINOR=$(echo "$CURRENT" | cut -d. -f2)
  PATCH=$(echo "$CURRENT" | cut -d. -f3)
  VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
fi

TAG="v$VERSION"
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Ensure tag doesn't already exist
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Error: tag $TAG already exists."
  exit 1
fi

echo "Releasing $CURRENT → $VERSION..."

# Get the current VERSION file SHA from main (needed for the update API)
FILE_SHA=$(gh api "repos/$REPO/contents/VERSION" --jq .sha)

# Update VERSION on main via GitHub API (bypasses branch protection for admins)
gh api "repos/$REPO/contents/VERSION" \
  --method PUT \
  --field message="Release $TAG" \
  --field content="$(echo -n "$VERSION" | base64)" \
  --field sha="$FILE_SHA" \
  --field branch="main" \
  > /dev/null

# Create tag pointing at latest main
MAIN_SHA=$(gh api "repos/$REPO/git/ref/heads/main" --jq .object.sha)
gh api "repos/$REPO/git/refs" \
  --method POST \
  --field ref="refs/tags/$TAG" \
  --field sha="$MAIN_SHA" \
  > /dev/null

# Update local VERSION file to stay in sync
echo "$VERSION" > VERSION

echo ""
echo "Tag $TAG pushed — GitHub Actions is building the Docker image."
echo "Follow progress: https://github.com/$REPO/actions"
echo ""
echo "Once the build completes (~5 min), update TrueNAS Scale:"
echo "  Apps > emuvault > Edit > set image tag to: $VERSION > Save"
echo "  (TrueNAS does not re-pull :latest on restart — a tag change forces it)"
