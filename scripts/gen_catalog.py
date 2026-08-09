#!/usr/bin/env python3
"""Generate the module catalog table in README.md from per-module metadata.

Every module under `modules/<provider>/<name>/` (except `_template`) declares a
`metadata.yaml`:

    provider: AWS
    status: stable
    summary: One-line description for the catalog table.

`provider` is the display name (AWS, GCP, "Replicate (REST)"), `status` is one of
experimental/beta/stable, and `summary` is a single line.

The generated table is written between the BEGIN_CATALOG / END_CATALOG markers in
README.md. Hand-editing the table is pointless — it gets overwritten. This exists
because a hand-maintained table is a merge-conflict generator: every parallel module
PR appends to the same lines.

    scripts/gen_catalog.py           # rewrite README.md in place
    scripts/gen_catalog.py --check   # exit 1 if README.md is out of date (CI)

Only the flat `key: value` subset of YAML is used, so this needs no third-party
parser. The repo's `check-yaml` pre-commit hook validates the files are real YAML.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MODULES_DIR = REPO_ROOT / "modules"
README = REPO_ROOT / "README.md"

BEGIN = "<!-- BEGIN_CATALOG -->"
END = "<!-- END_CATALOG -->"

REQUIRED_KEYS = ("provider", "status", "summary")
VALID_STATUSES = ("experimental", "beta", "stable")

# Sort providers into a stable, human-sensible order; anything unlisted sorts last.
PROVIDER_ORDER = ("AWS", "GCP")


def parse_metadata(path: Path) -> dict[str, str]:
    """Parse the flat `key: value` subset of YAML, ignoring comments and blanks."""
    data: dict[str, str] = {}
    for lineno, raw in enumerate(path.read_text().splitlines(), start=1):
        line = raw.strip()
        # Whole-line comments only — a trailing `#` is kept, since summaries may
        # legitimately contain one.
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            raise SystemExit(f"{path}:{lineno}: expected 'key: value', got {raw!r}")
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip("'\"")
    return data


def collect_modules() -> list[dict[str, str]]:
    modules = []
    errors = []
    for versions in sorted(MODULES_DIR.glob("*/*/versions.tf")):
        module_dir = versions.parent
        rel = module_dir.relative_to(MODULES_DIR).as_posix()
        meta_path = module_dir / "metadata.yaml"

        if not meta_path.exists():
            errors.append(f"{rel}: missing metadata.yaml")
            continue

        meta = parse_metadata(meta_path)
        missing = [k for k in REQUIRED_KEYS if not meta.get(k)]
        if missing:
            errors.append(f"{rel}: metadata.yaml missing {', '.join(missing)}")
            continue
        if meta["status"] not in VALID_STATUSES:
            errors.append(
                f"{rel}: status {meta['status']!r} not one of {'/'.join(VALID_STATUSES)}"
            )
            continue

        modules.append({"path": rel, **meta})

    if errors:
        raise SystemExit("catalog metadata errors:\n  " + "\n  ".join(errors))
    return modules


def render_table(modules: list[dict[str, str]]) -> str:
    def sort_key(m: dict[str, str]) -> tuple[int, str, str]:
        try:
            provider_rank = PROVIDER_ORDER.index(m["provider"])
        except ValueError:
            provider_rank = len(PROVIDER_ORDER)
        return (provider_rank, m["provider"], m["path"])

    rows = [
        "| Module | Provider | Status | Description |",
        "|--------|----------|--------|-------------|",
    ]
    for m in sorted(modules, key=sort_key):
        status = m["status"]
        if status != "stable":
            status = f"**{status}**"
        rows.append(
            f"| [`{m['path']}`](modules/{m['path']}) | {m['provider']} | "
            f"{status} | {m['summary']} |"
        )
    return "\n".join(rows)


def splice(readme: str, table: str) -> str:
    try:
        head, rest = readme.split(BEGIN, 1)
        _, tail = rest.split(END, 1)
    except ValueError:
        raise SystemExit(
            f"README.md is missing the {BEGIN} / {END} markers — add them around the "
            "module catalog table."
        )
    return f"{head}{BEGIN}\n{table}\n{END}{tail}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="exit non-zero if README.md is out of date instead of rewriting it",
    )
    args = parser.parse_args()

    modules = collect_modules()
    current = README.read_text()
    updated = splice(current, render_table(modules))

    if current == updated:
        print(f"catalog up to date ({len(modules)} modules)")
        return 0

    if args.check:
        print(
            "README.md module catalog is out of date. Run `make catalog` and commit "
            "the result.",
            file=sys.stderr,
        )
        return 1

    README.write_text(updated)
    print(f"catalog regenerated ({len(modules)} modules)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
