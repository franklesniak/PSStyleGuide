"""Native tests of the exact final Bash guard in disposable offline Git fixtures."""
from pathlib import Path
import hashlib,json,os,re,subprocess,tempfile,time

root=Path('/tmp/guard-fixtures');root.mkdir()
source=Path('/input/copilot-code-review.yml').read_bytes()
text=source.decode('utf-8')
tail=text.split('      - name: Verify final immutable setup inputs\n')
assert len(tail)==2
block=tail[1].split('        run: |\n',1)[1]
assert all(not line or line.startswith('          ') for line in block.splitlines())
script='\n'.join(line[10:] if line else '' for line in block.splitlines())+'\n'
assert 'git diff --cached --exit-code HEAD -- "${setup_inputs[@]}"' in script
assert 'git diff --exit-code HEAD -- "${setup_inputs[@]}"' in script
assert 'git ls-files --others -- "${setup_inputs[@]}"' in script
inputs=['package.json','package-lock.json','.github/workflows/package.json','.github/workflows/package-lock.json',
        '.github/workflows/ci-toolchain.json','requirements-dev.txt','.github/workflows/Invoke-LockedPythonHook.ps1',
        '.pre-commit-config.yaml','.github/workflows/install-husky.mjs','.husky/pre-commit','.github/workflows/lint-staged-markdown.mjs']
arr=script.split('declare -ar setup_inputs=(\n',1)[1].split(')',1)[0].split()
assert arr==inputs
env={k:v for k,v in os.environ.items() if not k.startswith(('GIT_','GH_','GITHUB_')) and k not in ('ACTIONS_RUNTIME_TOKEN',)}
env.update(GIT_CONFIG_NOSYSTEM='1',GIT_CONFIG_GLOBAL='/dev/null',GIT_TERMINAL_PROMPT='0')
def git(cwd,*args):
    r=subprocess.run(['/usr/bin/git','-c','core.hooksPath=/dev/null','-c','user.name=Fixture','-c','user.email=fixture@example.invalid','-c','commit.gpgsign=false',*args],cwd=cwd,env=env,capture_output=True,timeout=5)
    assert r.returncode==0,(args,r.returncode,r.stderr.decode())
    return r.stdout.decode().strip()
layouts={'legacy_node_only':inputs[2:4],'modern_node_only':inputs[:4],'modern_full':inputs}
cases=[]
def case(layout,label,action=None,path=None,expect=0):
    cwd=root/(layout+'-'+label);cwd.mkdir()
    git(cwd,'init','--quiet','--template=')
    (cwd/'.gitignore').write_text('package.json\nrequirements-dev.txt\n.github/workflows/ci-toolchain.json\n')
    (cwd/'anchor.txt').write_text('fixture\n')
    for item in layouts[layout]:
        p=cwd/item;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('baseline\n')
    git(cwd,'add','-f','--','.gitignore','anchor.txt',*layouts[layout])
    git(cwd,'commit','--quiet','-m','fixture baseline')
    present=[p for p in inputs if (cwd/p).exists()]
    if action:
        p=cwd/path;p.parent.mkdir(parents=True,exist_ok=True)
        if action in ('untracked','ignored','staged_add'):
            assert path not in present
            if action=='untracked':
                (cwd/'.gitignore').write_text('')
                git(cwd,'add','--','.gitignore');git(cwd,'commit','--quiet','-m','fixture ignore mode')
            p.write_text('injected\n')
            if action=='staged_add':git(cwd,'add','-f','--',path)
            if action=='ignored':
                r=subprocess.run(['/usr/bin/git','check-ignore','--',path],cwd=cwd,env=env,capture_output=True,timeout=5)
                assert r.returncode==0
        elif action=='modify':
            assert path in present;p.write_text('changed\n')
        elif action=='staged_delete':
            assert path in present;git(cwd,'rm','--',path)
        else:raise AssertionError(action)
    r=subprocess.run(['/bin/bash','--noprofile','--norc','-c',script],cwd=cwd,env=env,capture_output=True,timeout=5)
    assert (r.returncode==0)==(expect==0),(layout,label,r.returncode,r.stdout.decode(),r.stderr.decode())
    if expect==0:assert not r.stderr and not r.stdout
    cases.append({'layout':layout,'case':label,'action':action,'path':path,'baseline_present':present,
                  'expected':'pass' if expect==0 else 'reject','exit':r.returncode,'stdout':r.stdout.decode(),'stderr':r.stderr.decode()})
for layout in layouts:case(layout,'clean')
for layout,target in [('legacy_node_only','package.json'),('modern_node_only','requirements-dev.txt')]:
    for action in ('untracked','ignored','staged_add'):case(layout,action,action,target,1)
case('legacy_node_only','tracked-modify','modify','.github/workflows/package.json',1)
case('legacy_node_only','tracked-delete','staged_delete','.github/workflows/package-lock.json',1)
case('modern_node_only','tracked-modify','modify','package.json',1)
case('modern_full','tracked-modify','modify','requirements-dev.txt',1)
case('modern_full','tracked-delete','staged_delete','.github/workflows/ci-toolchain.json',1)
assert len(cases)==14
print(json.dumps({'status':'PASS_EXACT_GUARD_14_CONTROLS','git':git(root,'--version'),'workflow_sha256':hashlib.sha256(source).hexdigest(),
                  'guard_sha256':hashlib.sha256(script.encode()).hexdigest(),'cases':cases,
                  'scope':'Exact final Bash guard only; tiny synthetic Git contents do not claim full legacy dependency installation or hostile-writer safety.'},indent=2))
