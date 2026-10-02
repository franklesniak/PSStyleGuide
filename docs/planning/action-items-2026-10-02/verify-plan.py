"""Validate the split plan without GitHub writes or product execution."""
from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parent
errors = []
def check(condition, message):
    if not condition:
        errors.append(message)
def read_json(path):
    return json.loads((ROOT / path).read_text(encoding='utf-8'))

tasks = read_json('task-index.json')
historical = read_json('historical-map.json')
counts = read_json('evidence/historical-completion-counts.json')
by_id = {t['id']: t for t in tasks}
check(len(tasks) == len(by_id) == 20, 'Expected 20 unique active outcomes')
check(set(by_id) == {f'A{i:02}' for i in range(20)}, 'Unexpected active task IDs')
visiting, visited = set(), set()
def visit(id):
    if id in visiting:
        errors.append('Dependency cycle at ' + id)
        return
    if id in visited:
        return
    visiting.add(id)
    for dependency in by_id[id]['dependencies']:
        if dependency not in by_id:
            errors.append('Unknown dependency ' + dependency)
        else:
            visit(dependency)
    visiting.remove(id)
    visited.add(id)
for task in tasks:
    visit(task['id'])
    check(task['transfer_cap'] in (8, 12, 16), 'Bad transfer cap ' + task['id'])
    check(task['model'] in ('gpt-6-luna', 'gpt-6.1-sol', 'gpt-6-astra'), 'Unknown snapshot model')
    check(task['reasoning'] in ('low', 'medium', 'high'), 'Unsupported snapshot effort')
    body = (ROOT / task['file']).read_text(encoding='utf-8')
    for required in ('## Scope', '## Work', '## Validation', '## Complete when', '## Original requirements and restart', '80 rounds', '8 elapsed days'):
        check(required in body, f'{task["id"]} lacks {required}')
    check(f"`{task['model']}` / `{task['reasoning']}`" in body, 'Route mismatch ' + task['id'])

check([h['id'] for h in historical] == list(range(1,403)), 'Historical IDs not exactly 1..402')
check(len(list((ROOT/'original-tasks').glob('*.md'))) == 402, 'Wrong original task file count')
check(len(counts['previous_completed']) == 230, 'Previous completed count mismatch')
check(len(counts['verified_historical']) == 26, 'Verified historical count mismatch')
for h in historical:
    body = (ROOT/h['file']).read_text(encoding='utf-8')
    original_body = body.split('<!-- ORIGINAL CONTRACT START -->\n', 1)[1].split('<!-- ORIGINAL CONTRACT END -->', 1)[0]
    check(hashlib.sha256(original_body.encode()).hexdigest() == h['original_body_sha256'], 'Original contract altered: ' + str(h['id']))
    check(all(owner in by_id for owner in h['current_owners']), 'Unowned historical task ' + str(h['id']))
    check(bool(h['current_owners']), 'Empty original ownership')
    check(h['previous_completed'] == (h['id'] in counts['previous_completed']), 'Completion claim mismatch')
    check((h['original_audit_status']=='COMPLETE_VERIFIED') == (h['id'] in counts['verified_historical']), 'Historical credit mismatch')

source = ROOT.parent/'action-items-2026-08-30.md'
check(hashlib.sha256(source.read_bytes()).hexdigest()==counts['original_source_sha256'], 'August source changed')
snapshot = read_json('evidence/tree-union.json')
inventory = read_json('evidence/path-ownership.json')
union = set().union(*(set(t) for t in snapshot['trees'].values()))
check({p['path'] for p in inventory} == union, 'Path ownership does not cover full union')
check(len(inventory)==len(union)==81, 'Baseline tree count changed unexpectedly')
check(all(p['owner'] and p['exception_status']=='none approved' for p in inventory), 'Unowned or prematurely exempted path')
coverage = (ROOT/'ISSUE-COVERAGE.md').read_text(encoding='utf-8')
issue_count = 0
for repo in ('PSStyleGuide','TerraformStyleGuide'):
    for issue in read_json('evidence/'+repo+'-open-issues.json'):
        issue_count += 1
        check(issue['url'] in coverage, 'Issue lacks coverage: ' + issue['url'])
check(issue_count==5, 'Dated issue count mismatch')

# Check actionable local Markdown links, excluding quoted historical context.
files = [p for p in ROOT.rglob('*.md') if 'archive' not in p.relative_to(ROOT).parts]
files += [ROOT.parent/'coding-agent-loop.md', ROOT.parent/'action-items-2026-10-02.md', ROOT.parent/'coding-agent-loop-without-model-routing.md']
for path in files:
    body = path.read_text(encoding='utf-8')
    if 'original-tasks' in path.parts:
        body = body.split('<!-- ORIGINAL CONTRACT START -->')[0]
    for link in re.findall(r'\]\(([^)]+)\)', body):
        link = link.strip('<>').split('#',1)[0]
        if not link or re.match(r'^(?:https?:|mailto:|[A-Za-z]:)', link):
            continue
        check((path.parent/link).exists(), f'Broken local link in {path.name}: {link}')

# Decision arithmetic is worth checking because it selects the plan's behavior.
weights = {
    'DECISIONS.md': {'D01':[35,25,25,10,5],'D02':[35,30,20,10,5],'D03':[40,25,20,10,5],
                     'D04':[35,25,25,10,5],'D05':[35,30,20,10,5],'D06':[40,25,20,10,5]},
    'RETIREMENT-REVIEW.md': {'R01':[40,25,20,10,5],'R02':[38,27,20,10,5],'R03':[45,25,15,10,5],
                             'R04':[42,28,15,10,5],'R05':[44,21,20,10,5],'R06':[43,27,15,10,5],'R07':[41,29,15,10,5]},
    'REVIEW.md': {'CR1':[45,30,20,5],'CR2':[45,30,20,5],'CR3':[45,25,25,5],
                  'CR4':[55,25,15,5],'CR5':[60,15,20,5]}}
for filename, sections in weights.items():
    text=(ROOT/filename).read_text(encoding='utf-8')
    for name, w in sections.items():
        match=re.search(r'^## '+name+r':.*?$(.*?)(?=^## |\Z)',text,re.M|re.S)
        check(match is not None,'Missing decision '+name)
        if match:
            for row in re.findall(r'^\| [A-D] \|.+$',match[1],re.M):
                cells=[x.strip() for x in row.strip('|').split('|')]
                scores=[float(s) for s in cells[1:]]
                expected=sum(a*b for a,b in zip(w,scores[:-1]))/5
                check(len(scores)==len(w)+1 and abs(scores[-1]-expected)<0.001,f'{name} {cells[0]} total {scores[-1]} should be {expected:g}')

if errors:
    print('\n'.join(errors))
    raise SystemExit(1)
print(f'PASS: {len(tasks)} active tasks; 402 intact contracts; acyclic dependencies; 5 issues; 81 paths; links, routes, counts and decision arithmetic.')
