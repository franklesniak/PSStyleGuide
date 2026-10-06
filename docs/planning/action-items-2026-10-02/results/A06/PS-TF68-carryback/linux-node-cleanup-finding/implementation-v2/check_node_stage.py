"""Root-released pure qualification only; no child, product import or OS wait operation."""
import argparse
import copy
import hashlib
import json
import pathlib
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--execute-root-approved', action='store_true')
    parser.add_argument('--manifest', type=pathlib.Path, required=True)
    parser.add_argument('--approved-manifest-sha256', required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    assert __debug__ and args.execute_root_approved
    assert sys.platform == 'linux' and sys.version_info[:3] == (3, 12, 3)
    assert pathlib.Path(sys.executable).resolve() == pathlib.Path('/usr/bin/python3.12')
    here = pathlib.Path(__file__).resolve().parent
    assert args.output.parent.resolve() == pathlib.Path('/output') and not args.output.exists()
    sha = lambda data: hashlib.sha256(data).hexdigest()
    raw = args.manifest.read_bytes()
    assert sha(raw) == args.approved_manifest_sha256
    manifest = json.loads(raw)
    assert manifest['execution_authorized'] is True and manifest['authorizing_coordinator'] == 'root'
    assert manifest['role'] == 'pure-node-stage-judgment-qualification'
    for name, digest in manifest['prepared_files'].items():
        assert pathlib.PurePath(name).name == name
        assert sha((here / name).read_bytes()) == digest, name
    for name, digest in manifest['input_files'].items():
        assert pathlib.PurePath(name).name == name
        assert sha((here / 'inputs' / name).read_bytes()) == digest, name
    # Import only the two reviewed pure judgments after hash checks.
    from node_stage import require_node_stage, OBSERVER_SHA256
    from settlement import require_successful_exited_children

    def load(name):
        return json.loads((here / 'inputs' / name).read_bytes())

    saved_manifest = load('saved-manifest.json')
    saved_result, saved_status = load('saved-result.json'), load('saved-status.json')
    assert saved_result['state'] == saved_status['state'] == 'failed'
    assert saved_status['container_absent'] is True and saved_status['source_after_equal'] is True
    assert saved_manifest['prepared_files']['inside.py'] == OBSERVER_SHA256
    assert sha((here / 'inputs' / 'saved-inside.py').read_bytes()) == OBSERVER_SHA256
    assert saved_manifest['source_head'] == saved_manifest['accepted_base'] == manifest['accepted_base']
    assert saved_manifest['candidate_tree'] == manifest['candidate_tree']
    assert saved_manifest['expected_node_tests'] == 600
    assert len(load('saved-source-catalog.json')) == 78
    assert len(load('saved-dependency-catalog.json')) == 1914
    runtime = load('saved-runtime.json')['versions']
    assert runtime == {'node': 'v24.18.1', 'npm': '11.16.0', 'python': 'Python 3.12.3', 'pwsh': '7.6.3'}
    before, terminal = load('saved-private-before.json'), load('saved-private-terminal.json')
    host_before, host_after = load('saved-host-before.json'), load('saved-host-after.json')
    assert host_before['files'] == load('saved-source-catalog.json')
    deps = [{key: row[key] for key in ['path', 'sha256', 'bytes']} for row in load('saved-dependency-catalog.json')]
    assert host_before['dependencies'] == deps
    assert before == load('saved-preflight-after.json') == terminal and host_before == host_after
    assert saved_result.get('terminal_guard_error') is None
    preflight = next(row for row in saved_result['commands'] if row['name'] == 'staged-preflight')
    command = next(row for row in saved_result['commands'] if row['name'] == 'affected-node')
    assert preflight['state'] == 'passed' and preflight['exit'] == 0
    assert command['command'] == saved_manifest['node_command']
    receipt = load('saved-node-cleanup.json')
    node_receipts = [row['receipt'] for row in saved_result['cleanup_receipts'] if row['phase'] == 'affected-node']
    assert len(node_receipts) == 1 and node_receipts[0] == receipt
    assert saved_result['failure_type'] == 'AssertionError' and saved_result['failure'] == receipt['judgment_failure']
    assert sha((here / 'inputs' / 'saved-node.log').read_bytes()) == command['log_sha256']
    boundary = {'observer_sha256': OBSERVER_SHA256, 'single_async_command_in_phase': True,
                'private_terminal_equal': before == terminal, 'host_terminal_equal': host_before == host_after,
                'setup_anchor': saved_result['setup_anchor'], 'setup_cleanup': saved_result['setup_cleanup'],
                'preflight_cleanup': preflight['cleanup'], 'terminal_cleanup': saved_result['terminal_cleanup'],
                'terminal_anchor': saved_result['terminal_anchor']}
    original = {'command': command, 'tap': (here / 'inputs' / 'saved-node.log').read_text(encoding='utf-8'),
                'receipt': receipt, 'boundary': boundary}
    cases = []

    def judge(pack):
        return require_node_stage(pack['command'], pack['tap'], pack['receipt'], pack['boundary'])

    def case(name, expected, change=None):
        pack = copy.deepcopy(original)
        if change is not None:
            change(pack)
        frozen = copy.deepcopy(pack)
        try:
            interpretation = judge(pack)
            accepted, refusal = True, None
        except AssertionError as error:
            interpretation, accepted, refusal = None, False, str(error)
        assert pack == frozen, 'Judgment mutated qualification data'
        assert accepted == expected, (name, expected, accepted, refusal)
        cases.append({'case': name, 'expected_accepted': expected, 'observed_accepted': accepted, 'refusal': refusal})
        return interpretation

    def put(pack, section, key, value):
        pack[section][key] = value

    def core(row, **changes):
        row.update(changes)
        raw = row['raw_stat']
        split = raw.rfind(')')
        fields = raw[split + 2:].split()
        for index, key in [(0, 'state'), (1, 'ppid'), (2, 'group'), (3, 'session'), (19, 'start_ticks')]:
            fields[index] = str(row[key])
        prefix = raw[:split + 1]
        prefix = str(row['pid']) + prefix[prefix.index(' '):]
        row['raw_stat'] = prefix + ' ' + ' '.join(fields) + '\n'

    def one_wait(pack, status, exited, code, signaled, sig):
        pack['receipt']['members_before'] = pack['receipt']['members_before'][:1]
        pack['receipt']['waits'] = pack['receipt']['waits'][:1]
        pack['receipt']['waits'][0].update(raw_status=status, exited=exited, exit=code, signaled=signaled, signal=sig)

    def duplicate_pid_new_ticks(pack):
        row = copy.deepcopy(pack['receipt']['members_before'][0])
        wait = copy.deepcopy(pack['receipt']['waits'][0])
        core(row, start_ticks=row['start_ticks'] + 1)
        core(wait['identity'], start_ticks=row['start_ticks'])
        pack['receipt']['members_before'].append(row)
        pack['receipt']['waits'].append(wait)

    actual = case('saved600-and82-owned-terminal-observations', True)
    case('empty-owned-set', True, lambda p: p['receipt'].update(members_before=[], waits=[]))
    case('normal-nonzero-not-a128-allowlist', True, lambda p: one_wait(p, 42 << 8, True, 42, False, None))
    case('terminal-signal-not-aSIGKILL-allowlist', True, lambda p: one_wait(p, 15, False, None, True, 15))
    case('terminal-signal-with-core-bit', True, lambda p: one_wait(p, 15 | 128, False, None, True, 15))
    case('direct-Node-nonzero-even-with-no-residue', False, lambda p: (p['receipt'].update(members_before=[], waits=[]), put(p, 'command', 'exit', 1)))
    case('direct-Node-signaled', False, lambda p: put(p, 'command', 'exit', -9))
    case('unrelated-primary-failure', False, lambda p: put(p, 'command', 'failure', 'deadline reached'))
    case('primary-type-not-hidden-by-same-message', False, lambda p: put(p, 'command', 'failure_type', 'TimeoutExpired'))
    for key in ['direct_cleanup_failure', 'stream_cleanup_failure', 'terminal_receipt_failure']:
        case(key, False, lambda p, k=key: put(p, 'command', k, 'controlled failure'))
    case('wrong-stage', False, lambda p: put(p, 'command', 'name', 'aggregate'))
    case('wrong-seven-file-argv', False, lambda p: p['command']['command'].pop())
    case('missing-TAP-header', False, lambda p: p.update(tap=p['tap'].replace('TAP version 13', 'missing header')))
    case('missing-TAP-summary', False, lambda p: p.update(tap=p['tap'].replace('# tests 600', '# other 600')))
    case('duplicate-TAP-summary', False, lambda p: p.update(tap=p['tap'] + '\n# tests 600\n'))
    case('wrong-test-count', False, lambda p: p.update(tap=p['tap'].replace('# tests 600', '# tests 599')))
    for field in ['fail', 'cancelled', 'skipped', 'todo']:
        case('TAP-' + field, False, lambda p, f=field: p.update(tap=p['tap'].replace('# ' + f + ' 0', '# ' + f + ' 1')))
    case('private-input-drift', False, lambda p: put(p, 'boundary', 'private_terminal_equal', False))
    case('host-input-drift', False, lambda p: put(p, 'boundary', 'host_terminal_equal', False))
    case('unqualified-observer', False, lambda p: put(p, 'boundary', 'observer_sha256', '0' * 64))
    case('unknown-isolated-phase', False, lambda p: put(p, 'boundary', 'single_async_command_in_phase', False))
    case('nonempty-earlier-boundary', False, lambda p: p['boundary']['preflight_cleanup'].update(members_before=[copy.deepcopy(p['receipt']['members_before'][0])]))
    case('terminal-collection-error', False, lambda p: p['boundary']['terminal_cleanup'].update(failure='controlled terminal error'))
    case('foreign-owner', False, lambda p: put(p, 'receipt', 'owner_pid', p['receipt']['owner_pid'] + 1))
    case('foreign-earlier-owner', False, lambda p: p['boundary']['preflight_cleanup'].update(owner_pid=99))
    case('live-before-eventual-empty', False, lambda p: core(p['receipt']['members_before'][0], state='S'))
    case('unknown-before-state', False, lambda p: core(p['receipt']['members_before'][0], state='?'))
    case('identity-born-before-Node', False, lambda p: core(p['receipt']['members_before'][0], start_ticks=0))
    case('raw-process-identity-mismatch', False, lambda p: p['receipt']['members_before'][0].update(start_ticks=1))
    case('missing-wait', False, lambda p: p['receipt']['waits'].pop())
    case('duplicate-wait', False, lambda p: p['receipt']['waits'].append(copy.deepcopy(p['receipt']['waits'][0])))
    case('duplicate-member', False, lambda p: p['receipt']['members_before'].append(copy.deepcopy(p['receipt']['members_before'][0])))
    case('simultaneous-same-PID-different-birth', False, duplicate_pid_new_ticks)
    case('mismatched-wait-identity', False, lambda p: core(p['receipt']['waits'][0]['identity'], start_ticks=p['receipt']['waits'][0]['identity']['start_ticks'] + 1))
    case('foreign-adopted-parent', False, lambda p: core(p['receipt']['waits'][0]['identity'], ppid=99))
    case('observer-signal-before-eventual-empty', False, lambda p: put(p, 'receipt', 'signals', [{'signal': 9}]))
    case('collection-error', False, lambda p: put(p, 'receipt', 'failure', 'controlled collection error'))
    case('empty-after-unconfirmed', False, lambda p: put(p, 'receipt', 'empty_after', False))
    case('residue', False, lambda p: put(p, 'receipt', 'members_after', [copy.deepcopy(p['receipt']['members_before'][0])]))
    case('negative-raw-status', False, lambda p: p['receipt']['waits'][0].update(raw_status=-1))
    case('stopped-not-terminal', False, lambda p: p['receipt']['waits'][0].update(raw_status=(19 << 8) | 127))
    case('continued-not-terminal', False, lambda p: p['receipt']['waits'][0].update(raw_status=65535))
    case('wrong-decoded-exit', False, lambda p: p['receipt']['waits'][0].update(exit=7))
    case('wrong-decoded-terminal-kind', False, lambda p: p['receipt']['waits'][0].update(signaled=True))
    case('normal-exit-with-signal', False, lambda p: p['receipt']['waits'][0].update(signal=9))
    case('wrong-decoded-signal', False, lambda p: p['receipt']['waits'][-1].update(signal=15))
    case('signal-with-impossible-upper-exit-byte', False, lambda p: one_wait(p, (42 << 8) | 15, False, None, True, 15))

    for name, status_value, exited, code, signaled, sig in [
        ('strict-still-refuses-owned-nonzero', 42 << 8, True, 42, False, None),
        ('strict-still-refuses-owned-signal', 15, False, None, True, 15)]:
        pack = copy.deepcopy(original)
        one_wait(pack, status_value, exited, code, signaled, sig)
        try:
            require_successful_exited_children(pack['receipt'])
        except AssertionError:
            cases.append({'case': name, 'expected_accepted': False, 'observed_accepted': False})
        else:
            raise AssertionError('Unchanged strict default accepted ' + name)
    for name, digest in manifest['input_files'].items():
        assert sha((here / 'inputs' / name).read_bytes()) == digest, name
    for name, digest in manifest['prepared_files'].items():
        assert sha((here / name).read_bytes()) == digest, name
    record = {'state': 'qualified_pure_Node_stage_judgment_and_saved_evidence_interpretation',
              'manifest_sha256': sha(raw), 'cases': cases, 'composite_Node_interpretation': actual,
              'original_packet_status': 'failed_unchanged', 'historical_per_test_causes': 'unknown',
              'missing_aggregate': 'independent_root_evidence_required',
              'product_tests': 0, 'child_processes': 0, 'OS_wait_calls': 0,
              'input_files_unchanged': True, 'Linux_Python': sys.version}
    args.output.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
