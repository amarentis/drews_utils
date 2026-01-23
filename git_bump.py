#!/usr/bin/env python3
"""
Bump Poetry version in pyproject.toml (patch/minor/major), commit it, then create & push a semantic git tag.

Usage:
    python bump_tag.py patch
    python bump_tag.py minor
    python bump_tag.py major
    python bump_tag.py --help

Requirements:
    - Git installed
    - GitPython: pip install GitPython
    - Python 3.11+ (uses tomllib); for 3.10 or older: pip install tomli
"""

import sys
import tomllib  # Built-in in Python 3.11+
from pathlib import Path
from typing import Tuple

from git import Repo, InvalidGitRepositoryError, GitCommandError


def read_pyproject_version() -> Tuple[str, Path]:
    """Read current version from pyproject.toml under [tool.poetry.version]"""
    pyproject_path = Path("pyproject.toml")
    if not pyproject_path.is_file():
        raise FileNotFoundError("pyproject.toml not found in current directory")

    with open(pyproject_path, "rb") as f:
        data = tomllib.load(f)

    try:
        version = data["tool"]["poetry"]["version"]
    except (KeyError, TypeError):
        raise KeyError("Could not find tool.poetry.version in pyproject.toml")

    return version, pyproject_path


def bump_semver_version(version: str, part: str) -> str:
    """Bump patch, minor, or major in a semver string (e.g. '1.2.3')."""
    major, minor, patch = map(int, version.split("."))

    if part == "patch":
        patch += 1
    elif part == "minor":
        minor += 1
        patch = 0
    elif part == "major":
        major += 1
        minor = 0
        patch = 0
    else:
        raise ValueError(f"Unsupported bump part: {part} (use patch, minor, or major)")

    return f"{major}.{minor}.{patch}"


def update_pyproject_version(new_version: str, path: Path):
    """Update version in pyproject.toml (simple string replacement)."""
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    in_poetry_section = False
    updated = False

    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped == "[tool.poetry]":
            in_poetry_section = True
            continue
        if in_poetry_section and stripped.startswith("["):
            in_poetry_section = False  # exited section
        if in_poetry_section and stripped.startswith("version ="):
            # Replace version line (assumes it's quoted)
            old_version_line = f'version = "{read_pyproject_version()[0]}"'
            new_version_line = f'version = "{new_version}"'
            lines[i] = line.replace(old_version_line, new_version_line)
            updated = True
            break

    if not updated:
        raise RuntimeError("Failed to locate and update version line in pyproject.toml")

    path.write_text("".join(lines), encoding="utf-8")


def main():
    if len(sys.argv) != 2 or sys.argv[1] in ("--help", "-h"):
        print(__doc__)
        return 0

    bump_type = sys.argv[1].lower()
    if bump_type not in ("patch", "minor", "major"):
        print("Error: Must specify 'patch', 'minor', or 'major'")
        return 1

    try:
        repo = Repo(search_parent_directories=True)
    except InvalidGitRepositoryError:
        print("Error: Not inside a git repository")
        return 1

    if repo.is_dirty():
        print("Error: Working directory is dirty. Commit or stash changes first.")
        return 1

    # Step 1: Read current version from pyproject.toml
    try:
        current_version, pyproject_path = read_pyproject_version()
    except (FileNotFoundError, KeyError) as e:
        print(f"Error reading pyproject.toml: {e}")
        return 1

    print(f"Current version in pyproject.toml: {current_version}")

    # Step 2: Calculate new version
    new_version = bump_semver_version(current_version, bump_type)
    print(f"Bumping {bump_type} → new version: {new_version}")

    # Step 3: Update pyproject.toml
    try:
        update_pyproject_version(new_version, pyproject_path)
        print("Updated pyproject.toml")
    except Exception as e:
        print(f"Failed to update pyproject.toml: {e}")
        return 1

    # Step 4: Commit the change
    try:
        repo.index.add([str(pyproject_path)])
        repo.index.commit(f"Bump version to {new_version} ({bump_type})")
        print("Committed version bump")
    except GitCommandError as e:
        print(f"Git commit failed: {e}")
        return 1

    # Step 5: Create and push tag (with 'v' prefix; remove 'v' if you prefer plain numbers)
    new_tag = f"v{new_version}"
    try:
        repo.create_tag(new_tag, message=f"Release {new_tag}")
        print(f"Created annotated tag: {new_tag}")

        origin = repo.remote("origin")
        origin.push(new_tag)
        print(f"Pushed tag {new_tag} to origin")
    except GitCommandError as e:
        print(f"Git tag/push failed: {e}")
        return 1

    print("Done! You may now want to run:")
    print("  poetry build && poetry publish")
    print("  # or create a GitHub release manually")
    return 0


if __name__ == "__main__":
    sys.exit(main())