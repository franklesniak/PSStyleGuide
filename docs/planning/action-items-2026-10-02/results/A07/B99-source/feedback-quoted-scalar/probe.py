from pathlib import Path
import datetime, hashlib, importlib.metadata, json, subprocess, sys

r=Path(__file__).parent
assert not (r/'result.json').exists()
assert sys.version_info[:2]==(3,12)
assert importlib.metadata.version('pre-commit')=='4.6.2'
client=Path(sys.prefix)/'Lib/site-packages/pre_commit/clientlib.py'
assert hashlib.sha256(client.read_bytes()).hexdigest()=='074619194fa0b2a7d4d7599f936b19abd8185340747c2d8343070ba8599fb85d'
from pre_commit.clientlib import load_config
repo='C:/Users/flesniak/.codex/worktrees/governance-push-exit/PSStyleGuide'
original=subprocess.check_output(['git','--no-optional-locks','-C',repo,'show','98177628b7bc02c646724bfc8aa0fd73fed0cd24:.pre-commit-config.yaml']).decode('utf-8')
needle='      - id: agent-instruction-contract\n'
assert original.count(needle)==1
mutant=original.replace(needle,'        description: "\n'+needle).rstrip()+'\n        #"\n'
(r/'original.yaml').write_text(original,encoding='utf-8',newline='\n')
(r/'masked.yaml').write_text(mutant,encoding='utf-8',newline='\n')
before=load_config(str(r/'original.yaml'))
after=load_config(str(r/'masked.yaml'))
before_ids=[h['id'] for group in before['repos'] for h in group['hooks']]
after_ids=[h['id'] for group in after['repos'] for h in group['hooks']]
assert len(before_ids)==11 and len(after_ids)==10
assert before_ids[:-1]==after_ids
assert 'agent-instruction-contract' not in after_ids
assert '- id: agent-instruction-contract' in after['repos'][-1]['hooks'][-1]['description']
result={'status':'PRIVATE_NATIVE_QUOTED_SCALAR_HIDING_REPRODUCED','recorded_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'python':sys.version,'pre_commit':'4.6.2','clientlib_sha256':hashlib.sha256(client.read_bytes()).hexdigest(),'original_ids':before_ids,'masked_ids':after_ids,'change':'Eight-space description: opening double quote before agent hook; eight-space comment-looking closing quote line after hook.','both_pass_native_schema':True,'candidate_validator_executed':False,'hooks_executed':False,'scope':'Native configuration-data characterization only. Same P1 ambiguity class; no candidate acceptance or validation.','files':{name:hashlib.sha256((r/name).read_bytes()).hexdigest() for name in ['original.yaml','masked.yaml','probe.py']}}
(r/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'status':result['status'],'original_hooks':len(before_ids),'masked_hooks':len(after_ids),'candidate_executed':False}))
