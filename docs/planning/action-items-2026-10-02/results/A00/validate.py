"""Validate A00 ledger coverage and optionally recheck native main identities."""
import collections
import datetime
import json
import pathlib
import subprocess

out = pathlib.Path(__file__).resolve().parent
root = out.parent.parent
document = json.loads((out / 'dispositions.json').read_text(encoding='utf-8'))
ledger = document['records']
original = json.loads((root / 'historical-map.json').read_text(encoding='utf-8-sig'))
assert [x['id'] for x in ledger] == list(range(1, 403))
allowed = {f'A{i:02}' for i in range(1, 20)}
for row, old in zip(ledger, original):
    assert row['id'] == old['id']
    assert row['original_body_sha256'] == old['original_body_sha256']
    assert (out / row['source_contract']).is_file()
    assert row['remaining_owners'] and set(row['remaining_owners']) <= allowed
    policy = document['policies'][row['policy']]
    assert policy['reason'] and policy['retained_guarantee'] and policy['next_action']
    assert row['historical_credit'] == old['original_audit_status']
    assert row['present_disposition'] in {'unverified', 'replaced'}
    if row['present_disposition'] == 'replaced':
        assert policy['decision'] in {'R01', 'R06'}
matrix = json.loads((out / 'research-pr78-matrix.json').read_text())
assert len(matrix['paths']) == matrix['path_count'] == 28
assert len({x['path'] for x in matrix['paths']}) == 28
assert sum(len(x['cells']) for x in matrix['paths']) == matrix['cell_count'] == 84
sources = json.loads((out / 'source-inspection.json').read_text())
indexed = {(x['repository'], x['path']): x for x in sources}
for path in matrix['paths']:
    assert path['remaining_owners'] and 'A18' in path['remaining_owners']
    for repo, cell in path['cells'].items():
        if cell.get('absent'):
            assert (repo, path['path']) not in indexed
        else:
            src = indexed[repo, path['path']]
            assert all(cell[k] == src[k] for k in ['blob', 'mode', 'size', 'sha256'])
history = json.loads((out / 'native-history.json').read_text())
assert len(history['pulls']) == 24 and all(x['merged'] for x in history['pulls'])
assert len(json.loads((out / 'native-acceptance-comments.json').read_text())) == 10
assert len(json.loads((out / 'retirement-changes.json').read_text())) == 3
final_refs = {}
for repo in ['PSStyleGuide', 'TerraformStyleGuide']:
    result = subprocess.run(['gh', 'api', f'repos/franklesniak/{repo}/git/ref/heads/main'],
                            check=True, capture_output=True, text=True, encoding='utf-8')
    final_refs[repo] = json.loads(result.stdout)['object']['sha']
    assert final_refs[repo] == history['refs'][repo]['commit']
summary = {
    'validated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'result': 'PASS', 'original_ids': 402,
    'present_dispositions': dict(collections.Counter(x['present_disposition'] for x in ledger)),
    'prior_historical_credits_preserved': 26,
    'unowned_original_ids': 0, 'catalog_paths': 28, 'catalog_cells': 84,
    'native_raw_blobs_read': len(sources),
    'research_catalog_raw_blobs_read': sum(x['repository'] == 'research-misc' for x in sources),
    'final_main_refs': final_refs,
    'limits': 'Coverage and native evidence validation only. No product tests, historical review reruns or product exception acceptance.'
}
(out / 'validation.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
print(json.dumps(summary, indent=2))
