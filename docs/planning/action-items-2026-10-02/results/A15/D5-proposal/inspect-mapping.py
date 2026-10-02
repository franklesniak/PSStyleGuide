"""Inspect static proposal consistency; no repository code, fixtures or operations."""
from pathlib import Path
import csv, json, re, hashlib, itertools

root=Path(__file__).parent
rows=list(csv.DictReader((root/'case-oracle-mapping.tsv').open(encoding='utf-8'),delimiter='\t'))
ids={r['id'] for r in rows}
assert len(ids)==len(rows)
assert all(all(v for v in r.values()) for r in rows)
original={f'SM-{family}-{i:02}' for family,count in [('BASH-BACKUP',20),('PS-BACKUP',23),('PS-UTF8',15),('CONFIRM',69),('BASH-CORR',15),('BASH-PUSH',29),('BASH-RM',17),('ADDRESS',36)] for i in range(1,count+1)}
assert original<=ids and len(original)==224
phase_sets={'BACKUP':['PRECREATE','PULL-PARTIAL','VALIDATED','PUBLISH-UNCERTAIN'],
 'CORR':['PRELINK','LINK-UNCERTAIN','PREUNLINK','UNLINK-UNCERTAIN'],
 'PUSH':['PRECONFIRM','PREPUSH','REMOTE-UNKNOWN','VERIFY'],
 'RM':['PREDRYRUN','DRYRUN','PRECONFIRM','PRERM','REMOTE-UNKNOWN','VERIFY']}
signals={f'SM-BASH-SIGNAL-{family}-{phase}-{sig}-{cleanup}' for family,phases in phase_sets.items() for phase,sig,cleanup in itertools.product(phases,['HUP','INT','TERM'],['OK','FAIL'])}
assert len(signals)==108 and signals=={i for i in ids if i.startswith('SM-BASH-SIGNAL-')}
for row in rows:
    if row['id'] in signals:
        signal=row['id'].split('-')[-2]
        assert int(row['proposedStatus'])=={'HUP':129,'INT':130,'TERM':143}[signal]
        assert 'cleanup count1' in row['exactProposedOracle']
    if 'LOCAL_CORRUPTION_SOURCE' in row['id']:
        assert 'Windows' not in row['runtimeCells']
        assert row['fixture'] not in ['parent inside repository','parent inside shared root','parent mode not0700']
    if row['id'].startswith('SM-BASH-') or row['id']=='SM-ADDRESS-36':
        assert 'Windows' not in row['runtimeCells']
    if row['proposedStatus'].startswith('{'):
        assert json.loads(row['proposedStatus'])=={'success':1,'alreadyExistsFailure':1}
    else: assert int(row['proposedStatus']) in [0,64,65,66,67,68,69,70,71,72,73,74,129,130,143]

# Independent boundary assertions target the sampled defect and all sibling CreateNew
# outputs, without relying on the proposal builder's corrected-role variables.
create_roles={'STATE_BACKUP','PUSH_BACKUP','PUSH_VERIFY','RM_BACKUP','RM_VERIFY','RECOVERY_CURRENT','RECOVERY_VERIFY','PUSH_REVIEW','RM_MATCH','RM_REPORT','RECOVERY_OUTPUT','RECOVERY_REPORT','DIFF_CURRENT_SHOW','DIFF_PROPOSED_SHOW','DIFF_PROVIDER_SCHEMA','RM_RECHECK_MATCH'}
acl_cases={6,7,8,9,10,21,22,23,24,25,26}
index={r['id']:r for r in rows}
checked=0
for role in create_roles:
    for surface,numbers in [('WINDOWS',acl_cases),('POSIX',{2})]:
        for number in numbers:
            row=index[f'SM-ROLE-{surface}-{role}-{number:03}']
            assert 'after producer CreateNew' in row['fixture']
            assert 'actual post-CreateNew producer' in row['oracleScope']
            assert 'no path created' not in row['exactProposedOracle']
            assert 'exact candidate unlink attempted1 and succeeds' in row['exactProposedOracle']
            assert 'original ordinary owned identity and nlink1 independently re-proved' in row['exactProposedOracle']
            assert row['proposedStatus']=='65'
            checked+=1
    for number in range(1,7):
        row=index[f'SM-ROLE-CREATED-RETENTION-{role}-{number:03}']
        assert 'root retained' in row['exactProposedOracle']
        assert 'nativeExit29' in row['exactProposedOracle'] if number in (3,6) else 'delete/unlink0' in row['exactProposedOracle']
        assert ('Windows' not in row['runtimeCells']) if number<4 else row['runtimeCells'].startswith('Windows:')
for number in [1,2,3,4,5,11,13,14,15,16,17,18,19,20]:
    assert 'no path created' in index[f'SM-ROLE-WINDOWS-STATE_BACKUP-{number:03}']['exactProposedOracle']
command=index['SM-ROLE-POSIX-RM_COMMAND_BACKUP-002']
assert command['gate']=='B' and command['proposedStatus']=='71'
assert 'one exact local rm child started' in command['exactProposedOracle']
assert 'retained' in command['exactProposedOracle'] and 'no backup cleanup/delete' in command['exactProposedOracle']
for row in rows:
    if row['id'].startswith('SM-ROLE-BOUND-'): assert row['oracleScope']=='bound predicate only'
    if row['id'].startswith('SM-ROLE-WINDOWS-LOCAL_CORRUPT-') and 'after one successful' in row['fixture']:
        assert 'source unlink0' in row['exactProposedOracle'] and 'names retained' in row['exactProposedOracle']

oldrows=list(csv.DictReader((root/'prior-frozen-v1/case-oracle-mapping.tsv').open(encoding='utf-8'),delimiter='\t'))
oldindex={r['id']:r for r in oldrows}
assert set(oldindex)<=ids
changes={'oldIdsRemoved':0,'existingRowsChanged':sum(index[i]!=row for i,row in oldindex.items()),'appendedRows':len(ids-set(oldindex)),
         'knownOwnedPostcreationCasesChecked':checked,'phaseBoundaryCheck':'PASS (static oracle inspection only)'}
for sample in json.loads((root/'confirmation-boundary-inputs.json').read_text(encoding='utf-8')):
    address=sample['address']
    assert len(address.encode('ascii'))<=2048
    keys=re.findall(r'\[("(?:[^"\\]|\\.)*")\]',address)
    assert len(keys)==8
    for key in keys:
        decoded=json.loads(key)
        assert 1<=len(decoded.encode('ascii'))<=128
        assert re.fullmatch(r'[A-Za-z0-9_](?:[A-Za-z0-9_ .\-~:/@%+=,"\\]*[A-Za-z0-9_])?',decoded)
        assert json.dumps(decoded,separators=(',',':'))==key
    payload=json.dumps(['state-rm',sample['workspace'],sample['backend'],address,sample['digest'][:16]],separators=(',',':'))
    assert len(payload.encode())==sample['payloadBytes']
    assert hashlib.sha256(payload.encode()).hexdigest()==sample['payloadSha256']
counts={'existing':len(original),'signals':len(signals),'namedSplits':sum(bool(re.fullmatch(r'SM-(?:BASH-BACKUP|PS-BACKUP|PS-UTF8|CONFIRM|BASH-CORR|BASH-PUSH|BASH-RM|ADDRESS)-\d+',i)) and i not in original for i in ids)}
counts['unnamedAllocated']=len(rows)-counts['existing']-counts['signals']-counts['namedSplits']
receipt={'checks':'static proposal consistency only','pass':True,'counts':counts,'total':len(rows),'boundaryCorrection':changes,'executedProductTests':0,'realGateApprovals':0,
 'files':[{'name':p.name,'bytes':len(p.read_bytes()),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(root.iterdir()) if p.is_file() and p.name!='static-handoff.json']}
(root/'static-handoff.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'pass':True,'scope':'static consistency','counts':counts,'total':len(rows),'boundaryCorrection':changes},indent=2))
