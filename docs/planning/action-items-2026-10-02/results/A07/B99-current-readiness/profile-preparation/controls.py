"""Pure in-memory/file-fixture controls only; no native tools or product tests."""
from pathlib import Path
import copy
import datetime
import hashlib
import importlib.util
import json
import sys

ROOT = Path(__file__).resolve().parent
S = Path("C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-PS-carryback-20261006")
N = Path("C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A18-research-readiness-20261005/hook-applicability/selected-B99-native-readiness")
ORDINARY = S / "linux-final-aggregate/runs/ps-carryback-20261006-aggregate-one/output/aggregate.log"
NATIVE = N / "linux/cases/results.json"


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    spec = importlib.util.spec_from_file_location("d98_pure_profile", ROOT / "profile.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    ordinary = ORDINARY.read_bytes()
    native = json.loads(NATIVE.read_bytes())
    require_native = next(case for case in native["cases"] if case["name"] == "good-00")
    command = native["commands"][require_native["command_index"]]
    assert command["exit"] == 0 and command["stderr"] == ""
    b99 = command["stdout"].encode()
    assert sha(b99) == require_native["output_sha256"]
    assert len(ordinary.splitlines()) == 11
    # Deliberately not YAML and not an assembled B99 product config.
    config = b"PURE FIXTURE CONFIG IDENTITY; NOT A PRODUCT CONFIGURATION\n"
    paths = ("source.py", "package.json", ".pre-commit-config.yaml")
    env = {"PATH": "pure-fixture-only", "LANG": "C.UTF-8"}
    guards = {"source": sha(b"synthetic source"), "config": sha(config), "index": sha(b"synthetic index"), "dependencies": sha(b"synthetic dependencies")}
    binding = {"hooks": module.HOOKS, "guards": guards, "source_paths": paths, "environment_sha256": module.env_digest(env)}
    receipt = {"exit": 0, "argv": module.ARGV, "environment": env, "stdout": ordinary + b99, "stderr": b"", "before": guards.copy(), "after": guards.copy(), "config_bytes": config, "inventory": {"argv": ("git", "ls-files", "--cached", "-z"), "exit": 0, "stdout": b"\x00".join(path.encode() for path in paths) + b"\x00", "stderr": b""}}
    results = []

    def check(name, edit=None, bind_edit=None, native_call=False, expected_error=None):
        case = copy.deepcopy(receipt)
        frozen = copy.deepcopy(binding)
        if edit:
            edit(case)
        if bind_edit:
            bind_edit(frozen)
        try:
            answer = module.judge_native(case) if native_call else module.judge_fixture(case, frozen)
        except module.Rejected as error:
            assert expected_error is not None, (name, str(error))
            assert expected_error in str(error), (name, str(error), expected_error)
            results.append({"name": name, "expected": "reject", "state": "passed_pure_control", "reason": str(error)})
        else:
            assert expected_error is None, (name, "unexpected acceptance")
            assert answer["state"] == "pure_fixture_judgment_only" and answer["applicable_passes"] == 11 and answer["B99"] == "demonstrated N/A"
            results.append({"name": name, "expected": "fixture-only judgment", "state": "passed_pure_control"})

    def row(case, index, value):
        lines = case["stdout"].splitlines()
        lines[index] = value
        case["stdout"] = b"\n".join(lines) + b"\n"

    def mutate_line(case, index, old, new):
        line = case["stdout"].splitlines()[index]
        row(case, index, line.replace(old, new))

    check("positive synthetic composite, never product acceptance")
    check("native entry stays held", native_call=True, expected_error="held:")
    check("unknown hook name", lambda c: mutate_line(c, 0, b"check json", b"unknown check"), expected_error="identity")
    check("wrong known name/order", lambda c: row(c, 0, c["stdout"].splitlines()[1]), expected_error="identity")
    check("duplicate hook row", lambda c: row(c, 1, c["stdout"].splitlines()[0]), expected_error="duplicate")
    check("missing hook row", lambda c: c.update(stdout=b"\n".join(c["stdout"].splitlines()[1:]) + b"\n"), expected_error="twelve")
    check("extra hook row", lambda c: c.update(stdout=c["stdout"] + c["stdout"].splitlines()[0] + b"\n"), expected_error="twelve")
    check("malformed hook row", lambda c: row(c, 0, b"check json Passed"), expected_error="malformed")
    check("old hook skipped", lambda c: mutate_line(c, 0, b"Passed", b"(no files to check)Skipped"), expected_error="existing")
    check("old hook failed", lambda c: mutate_line(c, 0, b"Passed", b"Failed"), expected_error="existing")
    check("B99 falsely Passed", lambda c: mutate_line(c, 11, b"(no files to check)Skipped", b"Passed"), expected_error="B99")
    check("B99 wrong skip reason", lambda c: mutate_line(c, 11, b"(no files to check)", b"(suppressed)"), expected_error="malformed")
    check("B99 skipped without reason", lambda c: mutate_line(c, 11, b"(no files to check)", b""), expected_error="B99")
    check("native nonzero", lambda c: c.update(exit=1), expected_error="native aggregate")
    check("native signaled", lambda c: c.update(exit=-9), expected_error="native aggregate")
    check("Boolean exit is not a receipt", lambda c: c.update(exit=False), expected_error="native aggregate")
    check("hook selection suppressed by argv", lambda c: c.update(argv=(*module.ARGV, "--hook-stage", "manual")), expected_error="argv")
    check("SKIP present even empty", lambda c: c["environment"].update(SKIP=""), expected_error="suppression")
    check("suppression environment alias", lambda c: c["environment"].update(PRE_COMMIT_ALLOW_NO_CONFIG="1"), expected_error="suppression")
    check("unknown environment drift", lambda c: c["environment"].update(UNKNOWN="1"), expected_error="environment drift")
    for key in ("source", "config", "index", "dependencies"):
        check(key + " after drift", lambda c, key=key: c["after"].update({key: "0" * 64}), expected_error="drift")
    check("before guard missing", lambda c: c["before"].pop("source"), expected_error="drift")
    check("config bytes not known", lambda c: c.update(config_bytes=b"unknown config"), expected_error="configuration")
    check("stderr diagnostic prevents acceptance", lambda c: c.update(stderr=b"warning\n"), expected_error="stderr")
    check("unknown extra output", lambda c: c.update(stdout=c["stdout"] + b"unknown diagnostic\n"), expected_error="twelve")
    check("ANSI-hidden native output", lambda c: c.update(stdout=b"\x1b[0m" + c["stdout"]), expected_error="output controls")
    check("output decoding failure", lambda c: c.update(stdout=b"\xff"), expected_error="encoding")
    check("inventory missing receipt", lambda c: c.update(inventory=None), expected_error="inventory command")
    check("inventory filtered pathspec", lambda c: c["inventory"].update(argv=("git", "ls-files", "--cached", "-z", "*.py")), expected_error="unfiltered")
    check("inventory read nonzero", lambda c: c["inventory"].update(exit=1), expected_error="read failure")
    check("inventory read diagnostic", lambda c: c["inventory"].update(stderr=b"read problem"), expected_error="read failure")
    check("inventory incomplete", lambda c: c["inventory"].update(stdout=b"source.py\x00"), expected_error="incomplete")
    check("inventory unknown path", lambda c: c["inventory"].update(stdout=c["inventory"]["stdout"] + b"unknown.py\x00"), expected_error="incomplete")
    check("inventory truncated without NUL", lambda c: c["inventory"].update(stdout=c["inventory"]["stdout"][:-1]), expected_error="NUL")
    check("inventory duplicate path", lambda c: c["inventory"].update(stdout=c["inventory"]["stdout"] + b"source.py\x00"), expected_error="duplicate inventory")
    check("inventory unknown encoding", lambda c: c["inventory"].update(stdout=b"\xff\x00"), expected_error="encoding")
    for path in ("MODULE.PYC", "module.pyo", "module.pyd", "pkg/__PyCaChE__/data.txt"):
        check("complete inventory has match " + path, lambda c, path=path: c["inventory"].update(stdout=c["inventory"]["stdout"] + path.encode() + b"\x00"), lambda b, path=path: b.update(source_paths=(*b["source_paths"], path)), expected_error="matched")
    check("wrong hook ID binding", bind_edit=lambda b: b.update(hooks=(("unknown-id", module.HOOKS[0][1]), *module.HOOKS[1:])), expected_error="hook IDs")
    check("duplicate ID binding", bind_edit=lambda b: b.update(hooks=(module.HOOKS[0], module.HOOKS[0], *module.HOOKS[2:])), expected_error="hook IDs")
    check("bare caller applicability Boolean", bind_edit=lambda b: b.update(applicable=False), expected_error="qualified binding")
    check("claimed skip count cannot authorize", lambda c: c.update(skips=1), expected_error="exact aggregate receipt")
    record = {"state": "passed_pure_fixture_controls_only", "finished_at": datetime.datetime.now(datetime.timezone.utc).isoformat(), "python": sys.version, "executable": sys.executable, "control_count": len(results), "controls": results, "native_integration": "held; NATIVE_BINDING=None", "no_product_test_or_native_execution": True, "inputs": [{"path": str(p), "sha256": sha(p.read_bytes())} for p in (ORDINARY, NATIVE)], "payloads": {p.name: sha(p.read_bytes()) for p in (ROOT / "profile.py", ROOT / "controls.py")}, "limits": "Synthetic receipt uses saved native row text with synthetic guards/config/inventory; no assembled B99 configuration or native twelve-hook acceptance."}
    out = ROOT / "result.json"
    assert not out.exists(), "do not overwrite qualification result"
    out.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps({"state": record["state"], "controls": len(results), "result_sha256": sha(out.read_bytes())}))


if __name__ == "__main__":
    main()
