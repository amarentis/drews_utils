#!/usr/bin/env python3
"""
Bump git tag patch or minor version and create/push the new tag.

Usage:
    python bump_tag.py patch
    python bump_tag.py minor
    python bump_tag.py --help

Requirements:
    - Git installed
    - GitPython: pip install GitPython
"""

import sys
from git import Repo, InvalidGitRepositoryError, GitCommandError


def get_latest_semver_tag(repo: Repo) -> str | None:
    """Find the latest tag that looks like a semantic version (vX.Y.Z or X.Y.Z)"""
    tags = sorted(
        repo.tags,
        key=lambda t: tuple(map(int, str(t).lstrip("v").split("."))),
        reverse=True
    )

    for tag in tags:
        version_str = str(tag).lstrip("v")
        parts = version_str.split(".")
        if len(parts) == 3 and all(p.isdigit() for p in parts):
            return str(tag)
    return None


def bump_version(version: str, part: str) -> str:
    """Bump patch or minor version. Returns new version string without 'v' prefix."""
    major, minor, patch = map(int, version.lstrip("v").split("."))

    if part == "patch":
        patch += 1
    elif part == "minor":
        minor += 1
        patch = 0
    else:
        raise ValueError(f"Unsupported bump part: {part}")

    return f"{major}.{minor}.{patch}"


def main():
    if len(sys.argv) != 2 or sys.argv[1] in ("--help", "-h"):
        print(__doc__)
        return 0

    bump_type = sys.argv[1].lower()
    if bump_type not in ("patch", "minor"):
        print("Error: Must specify 'patch' or 'minor'")
        return 1

    try:
        repo = Repo(search_parent_directories=True)
    except InvalidGitRepositoryError:
        print("Error: Not inside a git repository")
        return 1

    if repo.is_dirty():
        print("Error: Working directory is dirty. Commit or stash changes first.")
        return 1

    current_tag = get_latest_semver_tag(repo)
    if not current_tag:
        print("No valid semantic version tag found (looking for X.Y.Z or vX.Y.Z)")
        return 1

    print(f"Current latest tag: {current_tag}")

    new_version_no_v = bump_version(current_tag, bump_type)
    new_tag = f"v{new_version_no_v}"   # you can change to just new_version_no_v if you prefer no 'v'

    print(f"Bumping {bump_type} → new tag: {new_tag}")

    try:
        # Create annotated tag
        repo.create_tag(new_tag, message=f"Bump {bump_type} version to {new_tag}")
        print(f"Created tag: {new_tag}")

        # Push the tag
        origin = repo.remote("origin")
        origin.push(new_tag)
        print(f"Pushed tag {new_tag} to origin")

    except GitCommandError as e:
        print(f"Git error: {e}")
        return 1

    print("Done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())