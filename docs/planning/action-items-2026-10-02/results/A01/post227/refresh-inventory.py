import collections,copy,datetime,hashlib,json,os,pathlib,subprocess
ROOT=pathlib.Path("C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A01-post227-20261003")
PLAN=pathlib.Path("C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A01")
prior=json.loads(pathlib.Path("C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A01-post226-20261003/native-tree-union-post226.json").read_text(encoding="utf-8"))
native=json.loads((ROOT/"native-census.json").read_text(encoding="utf-8"))
oldc=json.loads(pathlib.Path("C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A01-post226-20261003/native-census.json").read_text(encoding="utf-8"))
env=dict(os.environ,GIT_OPTIONAL_LOCKS="0")
def write(name,data): (ROOT/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n",encoding="utf-8",newline="\n")
refs={}; records={}; raw={}
for label,repo in (("PS","PSStyleGuide"),("TF","TerraformStyleGuide")):
 d=native["repos"][repo]; sha=d["ref"]["object"]["sha"]; tree=d["commit"]["tree"]["sha"]
 assert not d["native_tree"]["truncated"]
 entries=[x for x in d["native_tree"]["tree"] if x["type"]!="tree"]
 work="C:/Users/flesniak/GitHub/"+repo
 local=subprocess.check_output(["git","ls-tree","-rz","--full-tree",tree],cwd=work,env=env)
 lmap={}
 for row in local.split(b"\0"):
  if not row: continue
  head,path=row.split(b"\t",1); mode,typ,oid=head.decode("ascii").split()
  lmap[path.decode("utf-8")]={"mode":mode,"type":typ,"oid":oid}
 assert set(lmap)=={e["path"] for e in entries}
 ids=[e["sha"] for e in entries]
 batch=subprocess.run(["git","cat-file","--batch"],input=("\n".join(ids)+"\n").encode("ascii"),stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=work,env=env,check=True).stdout
 pos=0; rmap={}; bmap={}
 for e in entries:
  end=batch.index(b"\n",pos); oid,typ,size=batch[pos:end].decode("ascii").split(); size=int(size); pos=end+1
  b=batch[pos:pos+size]; pos+=size
  assert batch[pos:pos+1]==b"\n"; pos+=1
  assert oid==e["sha"] and typ==e["type"]=="blob" and e["mode"]=="100644" and size==e["size"]
  assert hashlib.sha1(b"blob "+str(size).encode()+b"\0"+b).hexdigest()==oid
  assert lmap[e["path"]]=={"mode":e["mode"],"type":e["type"],"oid":oid}
  rmap[e["path"]]={"mode":e["mode"],"type":typ,"oid":oid,"size":size,"raw_sha256":hashlib.sha256(b).hexdigest()}
  bmap[e["path"]]=b
 assert pos==len(batch)
 refs[label]={"repo":"franklesniak/"+repo,"commit":sha,"tree":tree}
 records[label]=rmap; raw[label]=bmap
oldpaths={x["path"]:x for x in prior["paths"]}
rows=[]; changed=[]
for path in sorted(set(records["PS"])|set(records["TF"])):
 ps=records["PS"].get(path); tf=records["TF"].get(path)
 status="PS-only" if tf is None else "TF-only" if ps is None else "equal" if ps["mode"]==tf["mode"] and ps["type"]==tf["type"] and raw["PS"][path]==raw["TF"][path] else "different"
 old=oldpaths.get(path,{})
 row={k:copy.deepcopy(v) for k,v in old.items() if k not in ("prior_83_status","changed_since_a71")}
 row.update(path=path,ps=ps,tf=tf,status=status,raw_equal=status=="equal",prior_post226_status=old.get("status"),changed_since_post226=ps!=old.get("ps") or tf!=old.get("tf"))
 rows.append(row)
 if row["changed_since_post226"]: changed.append({"path":path,"owner":row.get("primary_owner"),"old_ps":old.get("ps"),"new_ps":ps,"old_tf":old.get("tf"),"new_tf":tf,"prior_status":old.get("status"),"status":status})
counts={"PS":len(records["PS"]),"TF":len(records["TF"]),"union":len(rows),**dict(collections.Counter(r["status"] for r in rows))}
write("native-tree-union-post227.json",{"captured_utc":native["captured_utc"],"refs":refs,"counts":counts,"raw_verification":"All150 native-enumerated entries compared with exact local Git ls-tree -rz paths/modes/types/OIDs. Read raw blobs with git cat-file --batch; recomputed raw Git SHA1, size and SHA256. Direct byte comparison without normalization; all100644/blob. No working-tree input used.","paths":rows})
def issue_view(x): return {k:x.get(k) for k in ("number","id","title","body","state","comments","updated_at")}
def comment_view(x): return {k:x.get(k) for k in ("id","body","updated_at","user")}
issues={}; comments={}
for label,repo in (("PS","PSStyleGuide"),("TF","TerraformStyleGuide")):
 cur=native["repos"][repo]; old=oldc["repos"][repo]["issues"]
 issues[label]={"count":len(cur["issues"]),"numbers":[x["number"] for x in cur["issues"]],"body_title_state_count_timestamp_equal":list(map(issue_view,cur["issues"]))==list(map(issue_view,old))}
 oldcomments=oldc["repos"][repo]["comments"]
 comments[label]={k:{"count":len(v),"ids":[c["id"] for c in v],"complete_payload_equal":v==oldcomments[k]} for k,v in cur["comments"].items()}
 assert len(cur["issues"])<100 and len(cur["open_prs"])<100
 for i in cur["issues"]: assert len(cur["comments"][str(i["number"])])==i["comments"]<100
absent=json.loads((PLAN/"absent-path-coverage.json").read_text(encoding="utf-8"))
assert len(absent["paths"])==26
missing=[p["path"] for p in absent["paths"] if p["path"] in set(records["PS"])|set(records["TF"])]
assert not missing
write("comparison-post227.json",{"prior_refs":prior["refs"],"current_refs":refs,"prior_counts":prior["counts"],"current_counts":counts,"changed_paths":changed,"added_paths":sorted(set(records["PS"])-{p for p,r in oldpaths.items() if r.get("ps")}),"removed_paths":sorted({p for p,r in oldpaths.items() if r.get("ps")}-set(records["PS"])),"issues":issues,"comments":comments,"open_prs":{"PS":len(native["repos"]["PSStyleGuide"]["open_prs"]),"TF":len(native["repos"]["TerraformStyleGuide"]["open_prs"])},"historical_preservation":{"original_union":81,"original_obligations":402,"absent_both_paths":26,"all26_still_absent":True,"retirements_and_dispositions_unchanged":True},"bounded_conditional_inputs":{"A14":"Requires bounded refresh of unchanged five generation/caller blobs plus changed A07 runtime/setup coverage; see conditional-inputs.json. Prior generation-section and residual dispositions are retained.","A12":"Workflow YAML/check names unchanged frompost226; actual validation/helper coverage changed. See conditional-inputs.json. No settings enumeration/authority or immutable-enforcement claim.","A21":"Classifier pair changes to exact A21 frozen closure; validator/SelfTest/manifest unchanged. A07 callers are now native source; landed instruction gate is separate. Unmerged working-tree candidate excluded."}})
print(json.dumps({"refs":refs,"counts":counts,"changed":[x["path"] for x in changed],"issues":issues,"comments":comments,"absent26":True},indent=2))
