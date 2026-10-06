from pathlib import Path
import hashlib,json,logging,io,sys,importlib.metadata,datetime
from pre_commit.clientlib import load_config
r=Path(__file__).parent
capture=io.StringIO();handler=logging.StreamHandler(capture);logger=logging.getLogger('pre_commit');logger.addHandler(handler)
assert sys.version_info[:2]==(3,12)
assert importlib.metadata.version('pre-commit')=='4.6.2'
client=Path(sys.prefix)/'Lib/site-packages/pre_commit/clientlib.py'
assert hashlib.sha256(client.read_bytes()).hexdigest()=='074619194fa0b2a7d4d7599f936b19abd8185340747c2d8343070ba8599fb85d'
original=load_config(str(r/'original.yaml'));mutant=load_config(str(r/'masked.yaml'))
original_ids=[h['id'] for repo in original['repos'] for h in repo['hooks']]
mutant_ids=[h['id'] for repo in mutant['repos'] for h in repo['hooks']]
assert len(original_ids)==12 and len(mutant_ids)==11
assert 'no-tracked-compiled-python' in original_ids and 'no-tracked-compiled-python' not in mutant_ids
assert original_ids[:-1]==mutant_ids
assert '- id: no-tracked-compiled-python' in mutant['repos'][-1]['description']
warning=capture.getvalue();assert 'Unexpected key(s)' in warning and 'description' in warning
result={'status':'PRIVATE_NATIVE_CONFIG_MASKING_REPRODUCED','recorded_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'python':sys.version,'pre_commit':importlib.metadata.version('pre-commit'),'clientlib_sha256':hashlib.sha256(client.read_bytes()).hexdigest(),'original_actual_hook_ids':original_ids,'masked_actual_hook_ids':mutant_ids,'both_pass_native_schema':True,'warning':warning,'masking_change':'Insert four-space description: | before exact B99 tail.','candidate_validator_executed':False,'hooks_executed':False,'dependency_install':False,'native_profile_qualified':False,'network_requested':False,'limit':'Native schema/data-loading reproduction only; no hook, payload, PowerShell candidate or acceptance test executed. No fresh whole-environment package attestation.'}
(r/'result.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'status':result['status'],'original_hooks':len(original_ids),'masked_hooks':len(mutant_ids),'warning':warning}))
