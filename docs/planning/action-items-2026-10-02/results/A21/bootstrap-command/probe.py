import os, sys, json, hashlib
from pathlib import Path
import pip
import pip._internal.configuration as configuration
from pip._internal.commands import create_command
from pip._internal.req.req_file import get_line_parser
root=Path(__file__).parent
for key in list(os.environ):
    if key.upper().startswith("PIP_"): del os.environ[key]
user=root/"user.ini"
user.write_text("[global]\nindex-url = https://user.invalid/simple\nextra-index-url = https://user-extra.invalid/simple\n",encoding="utf-8")
configuration.get_configuration_files=lambda: {configuration.kinds.GLOBAL:[],configuration.kinds.USER:[str(user)],configuration.kinds.SITE:[]}
canonical=["--isolated","--require-hashes","--only-binary=:all:","--index-url","https://pypi.org/simple","-r","requirements-dev.txt"]
rows=[]
for name,env,args in [("bare-user",{},["--requirement","requirements-dev.txt"]),("bare-env",{"PIP_INDEX_URL":"https://env.invalid/simple","PIP_EXTRA_INDEX_URL":"https://env-extra.invalid/simple"},["--requirement","requirements-dev.txt"]),("canonical-user-env",{"PIP_INDEX_URL":"https://env.invalid/simple","PIP_EXTRA_INDEX_URL":"https://env-extra.invalid/simple"},canonical)]:
    for key in list(os.environ):
        if key.startswith("PIP_"): del os.environ[key]
    os.environ.update(env)
    options,other=create_command("install",isolated="--isolated" in args).parse_args(args)
    rows.append(dict(case=name,index=options.index_url,extraIndexes=options.extra_index_urls,requireHashes=options.require_hashes,onlyBinary=sorted(options.format_control.only_binary)))
lineparser=get_line_parser(None)
_,hashopts=lineparser("--require-hashes")
_,binaryopts=lineparser("--only-binary=:all:")
assert rows[0]["index"]=="https://user.invalid/simple"
assert rows[1]["index"]=="https://env.invalid/simple"
assert rows[2]["index"]=="https://pypi.org/simple" and rows[2]["extraIndexes"]==[]
assert rows[2]["requireHashes"] and rows[2]["onlyBinary"]==[":all:"]
assert hashopts.require_hashes and binaryopts.format_control.only_binary=={":all:"}
sources=[]
for f in [Path(configuration.__file__),Path(pip.__file__).parent/"_internal/cli/main.py",Path(pip.__file__).parent/"_internal/req/req_file.py"]:
    sources.append(dict(path=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest()))
print(json.dumps(dict(python=sys.version,pip=pip.__version__,cases=rows,requirementsDirectives=dict(requireHashes=hashopts.require_hashes,onlyBinary=sorted(binaryopts.format_control.only_binary)),sources=sources,limits="Parser only, no installer/network; configuration search locations replaced with one scratch user file and empty global/site lists. --isolated still permits global/site and explicit PIP_CONFIG_FILE per inspected pip source; no total hermeticity claim."),indent=2))
