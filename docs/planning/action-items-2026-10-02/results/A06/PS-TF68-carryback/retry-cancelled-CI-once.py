"""One owner-authorized hourly rerun; reconcile native state before any repeat."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).parent
STATE = ROOT / 'execution-state.json'
RECEIPT = ROOT / 'round1-CI-retry-one.json'
PREFIX = 'repos/franklesniak/PSStyleGuide/'
RUN_ID = 37524396256


def now():
    return datetime.datetime.now(datetime.timezone.utc)


def stamp(value):
    return datetime.datetime.fromisoformat(value.replace('Z', '+00:00'))


def read_api(endpoint):
    return json.loads(subprocess.check_output(['gh', 'api', PREFIX + endpoint], timeout=60))


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8', newline='\n')


assert sys.argv[1:] == ['--issue-one-authorized-rerun']
assert not RECEIPT.exists(), 'Existing intent/result must be reconciled; do not repeat.'
state = json.loads(STATE.read_bytes())
assert state['pr'] == 235 and state['repository'] == 'franklesniak/PSStyleGuide'
assert now() >= stamp(state['CI_retry']['next_conservative_attempt_not_before'])
assert now() < stamp(state['review_rounds'][0]['deadline'])
assert not state['CI_retry']['retry_requested']
baseline = ROOT / 'round1-CI-retry-one-baseline.json'
assert not baseline.exists(), 'Inspect the existing baseline before another attempt.'
subprocess.run([sys.executable, '-X', 'utf8', str(ROOT / 'native-snapshot-compact.py'), baseline.name], check=True, timeout=180, stdout=subprocess.DEVNULL)
observed = json.loads(baseline.read_bytes())
assert not observed['pr']['merged'] and observed['pr']['state'] == 'open'
assert all(thread['isResolved'] for thread in observed['complete_review_threads'])
runs = [row for page in observed['complete_paginated_collections']['workflow_runs'] for row in page['workflow_runs']]
assert all(row['status'] == 'completed' and row['conclusion'] == 'success' for row in runs if row['id'] != RUN_ID)
assert len([row for row in runs if row['id'] == RUN_ID]) == 1
pr = read_api('pulls/235')
run = read_api(f'actions/runs/{RUN_ID}')
assert pr['head']['sha'] == state['head'] and pr['base']['sha'] == state['base'] and not pr['merged']
assert hashlib.sha256(pr['body'].encode()).hexdigest() == state['body_sha256']
assert run['head_sha'] == state['head'] and run['run_attempt'] == 1
assert run['status'] == 'completed' and run['conclusion'] == 'cancelled' and run['event'] == 'dynamic'
intent = now()
record = {'status': 'request_intent', 'requested_at': intent.isoformat(), 'head': state['head'], 'base': state['base'],
          'body_sha256': state['body_sha256'], 'round': 1, 'deadline': state['review_rounds'][0]['deadline'],
          'run_id': RUN_ID, 'prior_attempt': 1, 'baseline': str(baseline), 'before': run,
          'transport': 'documented Actions workflow-run rerun REST endpoint',
          'reason': 'Owner-authorized retry of cancelled CI, not a request solely to replace Lite review',
          'next_attempt_not_before': (intent + datetime.timedelta(hours=1)).isoformat()}
save(RECEIPT, record)
state['CI_retry'].update(retry_requested=True, last_request_attempt_at=intent.isoformat(),
                         next_conservative_attempt_not_before=record['next_attempt_not_before'], pending_receipt=str(RECEIPT))
save(STATE, state)
try:
    result = subprocess.run(['gh', 'api', '--method', 'POST', PREFIX + f'actions/runs/{RUN_ID}/rerun'], capture_output=True, timeout=60)
    record.update(command_exit=result.returncode, response=result.stdout.decode(), diagnostic=result.stderr.decode(),
                  status='transport_returned_reconciliation_pending')
except subprocess.TimeoutExpired:
    record.update(status='transport_timeout_ambiguous_no_repeat')
save(RECEIPT, record)
try:
    after = read_api(f'actions/runs/{RUN_ID}')
    record['native_readback'] = after
    assert after['head_sha'] == state['head']
    if after['run_attempt'] == 2:
        record['status'] = 'rerun_accepted_attempt2'
        state['CI_retry'].update(last_relaunch_at=intent.isoformat(), accepted=True, observed_attempt=2)
    elif record.get('command_exit') not in (None, 0) and after['run_attempt'] == 1:
        record['status'] = 'request_rejected_attempt1_unchanged'
        state['CI_retry'].update(accepted=False, observed_attempt=1)
    else:
        record['status'] = 'acceptance_ambiguous_do_not_repeat'
except Exception as error:
    record['readback_error'] = str(error)
    record['status'] = 'acceptance_ambiguous_do_not_repeat'
record['recorded_at'] = now().isoformat()
save(RECEIPT, record)
state['CI_retry'].update(status=record['status'], receipt=str(RECEIPT))
state['updated_at'] = record['recorded_at']
save(STATE, state)
print(json.dumps({'status': record['status'], 'command_exit': record.get('command_exit'),
                  'diagnostic': record.get('diagnostic'), 'run_id': RUN_ID,
                  'observed_attempt': record.get('native_readback', {}).get('run_attempt'),
                  'next_attempt_not_before': record['next_attempt_not_before']}))
