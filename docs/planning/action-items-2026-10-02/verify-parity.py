"""Read committed Git bytes; report raw differences without approving exceptions.

Exit 0: all paths, types, modes and bytes match. Exit 2: raw differences exist.
Exit 1: inspection failed. The caller must separately validate necessary exceptions.
This tool does not fetch, checkout, write to a repository, or normalize content.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


def git(repo: str, *args: str) -> bytes:
    return subprocess.run(["git", "--no-replace-objects", "-C", repo, *args], check=True, capture_output=True).stdout


def inventory(repo: str, commit: str) -> dict:
    if not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", commit):
        raise ValueError("Use an exact lowercase full commit SHA, not a moving ref.")
    resolved = git(repo, "rev-parse", "--verify", commit + "^{commit}").decode().strip()
    if resolved != commit:
        raise ValueError("The input is not the exact commit identity.")
    tree = git(repo, "rev-parse", commit + "^{tree}").decode().strip()
    entries = {}
    for row in git(repo, "ls-tree", "-r", "-z", "--full-tree", commit).split(b"\0"):
        if not row:
            continue
        metadata, raw_path = row.split(b"\t", 1)
        mode, kind, oid = metadata.decode("ascii").split()
        path = raw_path.decode("utf-8", errors="surrogateescape")
        entry = {"mode": mode, "type": kind, "oid": oid}
        if kind == "blob":
            content = git(repo, "cat-file", "blob", oid)
            entry.update(bytes=len(content), sha256=hashlib.sha256(content).hexdigest())
        elif kind == "commit":
            entry["gitlink"] = oid
        else:
            raise ValueError("Unexpected tracked object type: " + kind)
        entries[path] = entry
    return {"commit": commit, "tree": tree, "entries": entries}


def compare(ps: dict, tf: dict) -> dict:
    rows = []
    counts = {"equal": 0, "different": 0, "PS-only": 0, "TF-only": 0}
    for path in sorted(set(ps["entries"]) | set(tf["entries"])):
        left, right = ps["entries"].get(path), tf["entries"].get(path)
        if left is None:
            status = "TF-only"
        elif right is None:
            status = "PS-only"
        else:
            keys = ("mode", "type", "bytes", "sha256", "gitlink")
            status = "equal" if all(left.get(k) == right.get(k) for k in keys) else "different"
        counts[status] += 1
        rows.append({"path": path, "status": status, "PS": left, "TF": right})
    return {"PS": {k: ps[k] for k in ("commit", "tree")},
            "TF": {k: tf[k] for k in ("commit", "tree")},
            "counts": counts, "paths": rows,
            "exception_approval": "none; raw comparison only",
            "limits": "Does not prove historical required capabilities, renamed counterpart equivalence, behavior, or necessity of exceptions."}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ps", required=True, help="PS repository checkout")
    parser.add_argument("--tf", required=True, help="TF repository checkout")
    parser.add_argument("--ps-ref", required=True, help="Exact PS commit SHA")
    parser.add_argument("--tf-ref", required=True, help="Exact TF commit SHA")
    parser.add_argument("--output", type=Path, help="Optional report file; fails if it already exists")
    args = parser.parse_args()
    try:
        result = compare(inventory(args.ps, args.ps_ref), inventory(args.tf, args.tf_ref))
        if args.output:
            with args.output.open("x", encoding="utf-8", newline="\n") as stream:
                json.dump(result, stream, indent=2, ensure_ascii=True)
                stream.write("\n")
        print(json.dumps({"PS": result["PS"], "TF": result["TF"], "counts": result["counts"]}))
        return 0 if result["counts"]["equal"] == len(result["paths"]) else 2
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print("Parity inspection failed: " + str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
