import concurrent.futures,datetime,json,subprocess,sys,pathlib
ROOT=pathlib.Path(__file__).parent
REPOS=('PSStyleGuide','TerraformStyleGuide')
def api(endpoint,pages=False):
 cmd=['gh','api',endpoint]+(['--paginate','--slurp'] if pages else [])
 result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True)
 data=json.loads(result.stdout.decode('utf-8'))
 if pages:
  assert isinstance(data,list) and all(isinstance(p,list) for p in data)
  assert not data or len(data[-1])<100
  return [x for page in data for x in page],{'pages':len(data),'per_page':100,'counts':[len(p) for p in data]}
 return data
records={}
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
 work={}
 for repo in REPOS:
  prefix='repos/franklesniak/'+repo+'/'
  for key,endpoint,pages in [('ref','git/ref/heads/main',False),('issues','issues?state=open&per_page=100',True),('open_prs','pulls?state=open&per_page=100',True)]:
   work[(repo,key)]=pool.submit(api,prefix+endpoint,pages)
 for repo in REPOS:
  row={}; pagination={}
  for key in ('ref','issues','open_prs'):
   result=work[(repo,key)].result()
   if key=='ref':row[key]=result
   else:row[key],pagination[key]=result
  row['issues_including_pulls']=row['issues'];row['issues']=[x for x in row['issues'] if 'pull_request' not in x]
  row['pagination']=pagination; records[repo]=row
 for repo in REPOS:
  row=records[repo]; prefix='repos/franklesniak/'+repo+'/'
  sha=row['ref']['object']['sha']; row['commit']=api(prefix+'git/commits/'+sha)
  row['native_tree']=api(prefix+'git/trees/'+row['commit']['tree']['sha']+'?recursive=1')
  assert not row['native_tree']['truncated']
  requests={str(i['number']):pool.submit(api,prefix+'issues/'+str(i['number'])+'/comments?per_page=100',True) for i in row['issues']}
  row['comments']={};row['pagination']['comments']={}
  for key,future in requests.items():row['comments'][key],row['pagination']['comments'][key]=future.result()
  for i in row['issues']:assert len(row['comments'][str(i['number'])])==i['comments']
  row['runs']=api(prefix+'actions/runs?event=push&head_sha='+sha+'&per_page=100')
  assert row['runs']['total_count']==len(row['runs']['workflow_runs'])<100
extra={}
for suffix in ('issues/156','issues/156/comments?per_page=100'):
 result=api('repos/franklesniak/PSStyleGuide/'+suffix,'comments' in suffix)
 extra[suffix]=result
result={'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'repos':records,'conditional_A14_closed_history':extra,'read_only':'Authenticated GETs only; complete collection pagination; no settings or mutation.'}
name=sys.argv[1] if len(sys.argv)>1 else 'native-census.json'
path=ROOT/name; assert not path.exists();path.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'file':str(path),'refs':{r:d['ref']['object']['sha'] for r,d in records.items()},'issues':{r:[i['number']for i in d['issues']]for r,d in records.items()},'open_prs':{r:[i['number']for i in d['open_prs']]for r,d in records.items()},'runs':{r:[(x['id'],x['name'],x['status'],x['conclusion'])for x in d['runs']['workflow_runs']]for r,d in records.items()}},indent=2))
