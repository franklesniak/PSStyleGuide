"""D98 finite evidence judgment prototype. No native candidate is qualified here."""
import hashlib
import json
import re

HOOKS = (
    ("check-json", "check json"),
    ("check-yaml", "check yaml"),
    ("end-of-file-fixer", "fix end of files"),
    ("trailing-whitespace", "trim trailing whitespace"),
    ("yamllint", "yamllint"),
    ("actionlint", "Lint GitHub Actions workflow files"),
    ("check-dependabot", "Validate Dependabot Config (v2)"),
    ("check-github-workflows", "Validate GitHub Workflows"),
    ("staged-markdown", "staged Markdown"),
    ("workflow-policy-contract", "workflow policy contract"),
    ("agent-instruction-contract", "agent instruction contract and mutation tests"),
    ("no-tracked-compiled-python", "reject tracked compiled Python artifacts"),
)
ARGV = ("/opt/psstyleguide-runtime/venv/bin/python", "-m", "pre_commit", "run", "--all-files")
PATTERN = re.compile(r"(?i)(^|/)__pycache__/|\.py[cod]$")
ROW = re.compile(r"(.*?)\.{3,}(\(no files to check\))?(Passed|Skipped|Failed)")
HASH = re.compile(r"[0-9a-f]{64}")
GUARDS = {"source", "config", "index", "dependencies"}
# Root must bind an independently qualified real candidate before integration.
# No caller Boolean, prepared prototype or synthetic control can release this.
NATIVE_BINDING = None


class Rejected(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise Rejected(message)


def digest(raw):
    require(type(raw) is bytes, "raw bytes required")
    return hashlib.sha256(raw).hexdigest()


def env_digest(env):
    require(type(env) is dict and all(type(k) is str and type(v) is str for k, v in env.items()), "environment receipt")
    return digest(json.dumps(env, sort_keys=True, separators=(",", ":")).encode())


def _judge(receipt, binding):
    """Only judge bound evidence; this does not establish binding authority."""
    require(type(binding) is dict and set(binding) == {"hooks", "guards", "source_paths", "environment_sha256"}, "exact qualified binding required")
    require(binding["hooks"] == HOOKS, "exact twelve unique hook IDs/names required")
    frozen = binding["guards"]
    require(type(frozen) is dict and set(frozen) == GUARDS and all(type(v) is str and HASH.fullmatch(v) for v in frozen.values()), "immutable guard binding")
    paths = binding["source_paths"]
    require(type(paths) is tuple and len(paths) > 0 and all(type(p) is str and p and not p.startswith("/") and "\x00" not in p and "\\" not in p for p in paths), "complete source catalog paths required")
    require(len(paths) == len(set(paths)), "duplicate catalog path")
    require(type(binding["environment_sha256"]) is str and HASH.fullmatch(binding["environment_sha256"]), "environment binding required")
    require(type(receipt) is dict and set(receipt) == {"exit", "argv", "environment", "stdout", "stderr", "before", "after", "config_bytes", "inventory"}, "complete exact aggregate receipt required")
    require(type(receipt["exit"]) is int and receipt["exit"] == 0, "native aggregate exit")
    require(receipt["argv"] == ARGV, "ordinary full aggregate argv required")
    env = receipt["environment"]
    require(type(env) is dict and not any(k.upper() in {"SKIP", "PRE_COMMIT_ALLOW_NO_CONFIG"} for k in env), "suppression environment")
    require(env_digest(env) == binding["environment_sha256"], "environment drift or suppression")
    require(receipt["before"] == frozen and receipt["after"] == frozen, "source/config/index/dependency drift")
    require(digest(receipt["config_bytes"]) == frozen["config"], "unknown configuration bytes")
    require(receipt["stderr"] == b"", "unexpected native stderr")
    stdout = receipt["stdout"]
    require(type(stdout) is bytes and len(stdout) <= 32768, "bounded raw output required")
    try:
        text = stdout.decode("utf-8", errors="strict")
    except UnicodeError as error:
        raise Rejected("output encoding") from error
    require("\x1b" not in text and "\x00" not in text and "\r" not in text.replace("\r\n", ""), "ambiguous output controls")
    lines = text.splitlines()
    require(len(lines) == len(HOOKS), "exact twelve native rows required")
    seen = set()
    outcomes = []
    for line, (hook_id, expected_name) in zip(lines, HOOKS):
        match = ROW.fullmatch(line)
        require(match is not None, "malformed or unknown native row")
        name, reason, status = match.groups()
        require(name not in seen, "duplicate native hook row")
        seen.add(name)
        require(name == expected_name, "unknown, missing or reordered hook identity")
        if hook_id == "no-tracked-compiled-python":
            require(status == "Skipped" and reason == "(no files to check)", "B99 must be native no-files skip")
            outcomes.append({"id": hook_id, "name": name, "native": status, "judgment": "N/A"})
        else:
            require(status == "Passed" and reason is None, "existing applicable hook must pass")
            outcomes.append({"id": hook_id, "name": name, "native": status, "judgment": "Passed"})
    inventory = receipt["inventory"]
    require(type(inventory) is dict and set(inventory) == {"argv", "exit", "stdout", "stderr"}, "complete inventory command receipt required")
    require(inventory["argv"] == ("git", "ls-files", "--cached", "-z"), "unfiltered tracked inventory required")
    require(type(inventory["exit"]) is int and inventory["exit"] == 0 and inventory["stderr"] == b"", "inventory read failure")
    raw = inventory["stdout"]
    require(type(raw) is bytes and len(raw) <= 1048576 and raw.endswith(b"\x00"), "bounded complete NUL inventory required")
    try:
        actual = tuple(part.decode("utf-8", errors="strict") for part in raw[:-1].split(b"\x00"))
    except UnicodeError as error:
        raise Rejected("inventory encoding") from error
    require(all(actual) and len(actual) == len(set(actual)), "empty or duplicate inventory path")
    require(set(actual) == set(paths), "inventory incomplete or unknown source path")
    require(not any(PATTERN.search(path) for path in actual), "tracked compiled/cache filename matched")
    return {"profile": "D98", "rows": outcomes, "applicable_passes": 11, "B99": "demonstrated N/A", "tracked_paths": len(actual), "matches": 0}


def judge_fixture(receipt, binding):
    """Explicitly synthetic qualification; never native product acceptance."""
    result = _judge(receipt, binding)
    return {"state": "pure_fixture_judgment_only", **result}


def judge_native(receipt):
    if NATIVE_BINDING is None:
        raise Rejected("held: no independently qualified actual candidate binding")
    result = _judge(receipt, NATIVE_BINDING)
    return {"state": "bound_native_profile_evidence", **result}
