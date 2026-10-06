"""Pure judgment for the one selected Node assertion-owner stage. No import-time action."""
import math
import os
import re
import signal

OBSERVER_SHA256 = 'fab36fc8daf64a1c57580c571705e0f681d8c2388707b9d7fb4692f7e5c71516'
NODE_COMMAND = ['node', '--test', '--test-reporter=tap',
    '.github/workflows/Classify-InstructionMaintenance.test.mjs',
    '.github/workflows/Validate-WorkflowPolicy.test.mjs',
    '.github/workflows/Test-CiHelpers.test.mjs',
    '.github/workflows/NpmTools.test.mjs',
    '.github/workflows/Check-NpmAudit.test.mjs',
    '.github/workflows/Test-LocalValidation.test.mjs',
    '.github/workflows/lint-markdown.test.mjs']


def integer(value, minimum=0):
    assert type(value) is int and value >= minimum, 'Invalid integer receipt'
    return value


def process_identity(row):
    """Check raw stat identity instead of trusting an isolated PID or comm."""
    raw = row['raw_stat']
    assert isinstance(raw, str) and len(raw) <= 8192
    end = raw.rfind(')')
    assert end > 0 and '(' in raw[:end]
    pid = int(raw.split(' ', 1)[0])
    fields = raw[end + 2:].split()
    assert len(fields) >= 20
    core = (integer(row['pid'], 1), integer(row['start_ticks']),
            integer(row['ppid']), row['state'], integer(row['group']), integer(row['session']))
    assert core == (pid, int(fields[19]), int(fields[1]), fields[0], int(fields[2]), int(fields[3])), 'Raw process identity mismatch'
    return core


def empty_boundary(receipt):
    assert receipt['failure'] is None and receipt['empty_after'] is True
    assert receipt['members_before'] == receipt['members_after'] == receipt['waits'] == receipt['signals'] == [], 'Earlier ownership boundary is not empty'


def terminal_wait(wait):
    """Use the qualified Linux Python wait macros; never wait for a process here."""
    raw = integer(wait['raw_status'])
    assert raw <= 65535 and not os.WIFSTOPPED(raw) and not os.WIFCONTINUED(raw), 'Not a terminal wait status'
    exited, signaled = os.WIFEXITED(raw), os.WIFSIGNALED(raw)
    assert exited != signaled
    assert type(wait['exited']) is bool and type(wait['signaled']) is bool
    assert wait['exited'] == exited and wait['signaled'] == signaled, 'Decoded terminal kind mismatch'
    if exited:
        assert type(wait['exit']) is int and wait['exit'] == os.WEXITSTATUS(raw)
        assert wait['signal'] is None, 'Normal exit has a signal'
    else:
        assert raw & 0xff00 == 0, 'Signaled status has an exit byte'
        assert wait['exit'] is None and type(wait['signal']) is int
        assert wait['signal'] == os.WTERMSIG(raw) and 0 < wait['signal'] < signal.NSIG, 'Decoded terminal signal mismatch'


def require_node_stage(command, tap, receipt, boundary):
    assert __debug__, 'Optimized Python is not qualified'
    assert command['name'] == 'affected-node' and command['command'] == NODE_COMMAND
    assert type(command['exit']) is int and command['exit'] == 0, 'Direct Node failed'
    for key in ['direct_cleanup_failure', 'stream_cleanup_failure', 'terminal_receipt_failure']:
        assert command.get(key) is None, key
    # The saved command is failed because its former strict policy refused it.
    # No different primary failure is converted into a successful assertion.
    if command['state'] == 'failed':
        assert command.get('failure_type') is None, 'A direct primary failure was recorded'
        assert isinstance(receipt.get('judgment_failure'), str) and receipt['judgment_failure']
        assert receipt.get('judgment') == 'failed'
        assert command.get('failure') == command.get('cleanup_failure') == receipt['judgment_failure'], 'Unrelated primary failure'
    else:
        assert command['state'] == 'passed' and command.get('failure') is None and command.get('cleanup_failure') is None
    assert isinstance(tap, str) and len(re.findall(r'(?m)^TAP version 13\s*$', tap)) == 1
    summary = {}
    for field in ['tests', 'pass', 'fail', 'cancelled', 'skipped', 'todo']:
        matches = re.findall(r'(?m)^# ' + field + r' (\d+)\s*$', tap)
        assert len(matches) == 1, 'Missing or ambiguous TAP summary: ' + field
        summary[field] = int(matches[0])
    assert summary['tests'] == summary['pass'] == 600
    assert all(summary[field] == 0 for field in ['fail', 'cancelled', 'skipped', 'todo'])
    assert boundary['observer_sha256'] == OBSERVER_SHA256, 'Unqualified isolated observer'
    assert boundary['single_async_command_in_phase'] is True
    assert boundary['private_terminal_equal'] is True and boundary['host_terminal_equal'] is True
    empty_boundary(boundary['setup_cleanup'])
    empty_boundary(boundary['preflight_cleanup'])
    empty_boundary(boundary['terminal_cleanup'])
    owner_core = process_identity(boundary['setup_anchor']['owner'])
    first, last = command['anchor'], command['finished_anchor']
    assert process_identity(first['owner'])[:2] == process_identity(last['owner'])[:2] == owner_core[:2], 'Owner identity changed'
    owner = integer(receipt['owner_pid'], 1)
    assert owner == owner_core[0]
    assert boundary['setup_cleanup']['owner_pid'] == boundary['preflight_cleanup']['owner_pid'] == owner, 'Earlier owner boundary changed'
    assert boundary['terminal_cleanup']['owner_pid'] == owner
    assert process_identity(boundary['terminal_anchor']['owner'])[:2] == owner_core[:2]
    hz = integer(first['clock_ticks_per_second'], 1)
    assert last['clock_ticks_per_second'] == hz
    start, finish = first['monotonic'], last['monotonic']
    assert type(start) in [int, float] and type(finish) in [int, float]
    assert math.isfinite(start) and math.isfinite(finish) and 0 <= start < finish
    direct = process_identity(command['identity'])
    assert direct[0] == command['pid'] and direct[0] != owner and direct[2] == owner
    assert owner_core[1] <= direct[1] and math.floor(start * hz) <= direct[1] <= math.floor(finish * hz)
    assert receipt['failure'] is None and receipt['empty_after'] is True
    assert receipt['members_after'] == [] and receipt['signals'] == [], 'Unsafe cleanup lifecycle'
    before, waits = receipt['members_before'], receipt['waits']
    assert isinstance(before, list) and isinstance(waits, list)
    members = {}
    member_pids = set()
    for row in before:
        core = process_identity(row)
        assert core[3] == 'Z' and core[2] == owner and core[0] != direct[0], 'Live or unknown adopted ownership'
        assert direct[1] <= core[1] <= math.floor(finish * hz), 'Identity outside Node phase'
        key = core[:2]
        assert key not in members and core[0] not in member_pids, 'Duplicate adopted identity or PID'
        member_pids.add(core[0])
        members[key] = core
    observed = {}
    wait_pids = set()
    for wait in waits:
        core = process_identity(wait['identity'])
        key = core[:2]
        assert integer(wait['wait_pid'], 1) == core[0]
        assert key in members and core == members[key], 'Unknown or mismatched adopted wait'
        assert key not in observed and core[0] not in wait_pids, 'Duplicate wait identity or PID'
        wait_pids.add(core[0])
        terminal_wait(wait)
        observed[key] = {'pid': core[0], 'start_ticks': core[1], 'raw_status': wait['raw_status'],
                         'exited': wait['exited'], 'exit': wait['exit'], 'signaled': wait['signaled'],
                         'signal': wait['signal'], 'original_test_cause': 'unclassified'}
    assert set(observed) == set(members), 'Missing adopted wait'
    return {'interpretation': 'Node assertions and owned terminal collection satisfy the selected stage contract',
            'TAP': summary, 'adopted_observations': list(observed.values()),
            'old_packet_status': 'failed_unchanged', 'per_test_historical_causes_proved': False}
