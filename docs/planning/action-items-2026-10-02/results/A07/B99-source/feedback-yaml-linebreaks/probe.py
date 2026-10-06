from pathlib import Path
import datetime, hashlib, importlib.metadata, json, sys

r=Path(__file__).parent
assert not (r/'result.json').exists()
assert sys.version_info[:2]==(3,12)
assert importlib.metadata.version('pre-commit')=='4.6.2'
client=Path(sys.prefix)/'Lib/site-packages/pre_commit/clientlib.py'
assert hashlib.sha256(client.read_bytes()).hexdigest()=='074619194fa0b2a7d4d7599f936b19abd8185340747c2d8343070ba8599fb85d'
from pre_commit.clientlib import load_config
source=r.parent/'feedback-quoted-scalar/original.yaml'
raw=source.read_bytes()
assert hashlib.sha256(raw).hexdigest()=='05a6616918d519d654041f6683e380b9fbf0c308bd58fd88118615e53607a738'
original=raw.decode('utf-8')
name='        name: workflow policy contract\n'
needle='      - id: agent-instruction-contract\n'
assert original.count(name)==1 and original.count(needle)==1
cases=[]
for label,sep in [('bare-CR','\r'),('NEL','\u0085'),('LS','\u2028'),('PS','\u2029')]:
    mutant=original.replace(name,'').replace(needle,'        # comment'+sep+'        name: "\n'+needle).rstrip()+'\n        #"\n'
    path=r/(label+'.yaml')
    path.write_bytes(mutant.encode('utf-8'))
    parsed=load_config(str(path))
    ids=[h['id'] for group in parsed['repos'] for h in group['hooks']]
    assert len(ids)==10 and 'agent-instruction-contract' not in ids,label
    assert '- id: agent-instruction-contract' in parsed['repos'][-1]['hooks'][-1]['name'],label
    cases.append({'separator':label,'codepoint':f'U+{ord(sep):04X}','native_schema_accepted':True,'active_hook_count':len(ids),'guard_is_inactive_text':True,'path':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
result={'status':'PRIVATE_NATIVE_YAML_LINEBREAK_HIDING_REPRODUCED','recorded_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'python':sys.version,'pre_commit':'4.6.2','cases':cases,'source_sha256':hashlib.sha256(raw).hexdigest(),'candidate_executed':False,'hooks_executed':False,'scope':'Same P1 finite-reader line-boundary mismatch; native data loader only; no repaired candidate execution or acceptance.'}
(r/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'status':result['status'],'cases':len(cases),'all_native_active_hook_counts': [c['active_hook_count'] for c in cases]}))
