# A06 Terraform implementation and focused validation

Product bytes are stable. No further worker edits are planned. All12authorized paths are ported from accepted PS98177628b7bc02c646724bfc8aa0fd73fed0cd24 onto TFe21b74fe0b56551008f78f9f2946cd2a0f9c19ce. Existing approved decisions apply; no new material finding remains.

The four changed PowerShell files pass parser and PSScriptAnalyzer1.24.0 with zero warnings/errors. The exact verified PowerShell7.6.5 executable ran the focused harness twice; each pass returned exit0 and156assertions. The verified Node24.18.1 executable ran the current TF policy CLI successfully; its casesPassed0 is validation-only, not mutation proof. Complete commands appear in focused-windows.json and focused-windows.ps1; raw logs and hashes are in implementation-evidence.json.

Final inspection proves all12postimages still equal their recorded raw SHA256; all67other tracked files retain accepted raw bytes. The Git index is untouched. All four generated TF outputs, the independent verify contract and actual TF semantic helper remain unchanged. The port retains all16TF wrapper modes and accepted R7/R10 harness bytes. No source PS change, dependency installation, configuration/ref write, aggregate run, protected-file edit, descendant or Windows5.1 bypass occurred.

Root owns the single qualified Linux aggregate, including actual TF semantic examples, generator twice and artifact gate; the Linux semantic helper expressly rejects a non-Linux host. Actual hosted Windows5.1/Windows7/Linux7 proof, staging/commit checks, independent quality and publication remain.

| Changed path | Raw SHA256 | Git blob |
| --- | --- | --- |
| .github/workflows/Classify-InstructionMaintenance.mjs | 2517e4fb96ae1d029450dca72ad048ef49416654fae55641c586f22a31e831e8 | d9802a71a9e257bcbd0b9d5055e9f3ed9f430343 |
| .github/workflows/Classify-InstructionMaintenance.test.mjs | ec524175f9a10dfb0825844707692de93f86b6bb0c182ed1d3a440d96aa7c5ff | 166d137206aff8f503911be9a569efbd204e023b |
| .github/workflows/Generate-StyleGuideArtifacts.ps1 | 19ab48af8cc9ed2ff719c31129986d1b9fbedb6653409dd30a09dbd5b81df2ba | ef2e3d08b54212da215790a8a61f4b259b5c81c8 |
| .github/workflows/Test-CiHelpers.test.mjs | 4e7fbf7636215c18cf3514fb4bf6db219e4407c070d27b8341fe60680926f6a9 | 3a62fde67925bc99285f8a0c3c74b53ac7f7f109 |
| .github/workflows/Test-ExactGitPathSet.ps1 | 796e6efe02d3ca4a817c6e1430f9c71fb9d6d4bd4cf6be21df512e19e3b49d30 | 76cad06fd918ac2405981d205814c7e8d85e4dc7 |
| .github/workflows/Test-StyleGuideArtifacts.ps1 | 656e4441e76a1f3db8fd1eb9955267bc44addb3d0fe86f07c956281f9c83bad8 | b3c9ad4caa86919ac1b66c457493f7d6b9d9b813 |
| .github/workflows/Test-StyleGuideGenerator.ps1 | f84730e95eb73aa7d58a9c2f0f8232921e70d28d576fd24e3a87c750f2da4efa | dcd0cb93354a74de4a5d8323a7018511323e8bbe |
| .github/workflows/Validate-WorkflowPolicy.mjs | f6333e7877b2ed39496185bb8a399e75ae183117f819003a7d0294a0e943517f | b68aa229ae32dae8ad62886e93e161f887f67a26 |
| .github/workflows/Validate-WorkflowPolicy.test.mjs | d1f646e16fc2c5417dafaa1c631e06421a62a94c28618a205affde61dfb4f5e5 | 3f4bb6c982b584aed1535e9ef04dd918f9069055 |
| .github/workflows/build.yml | f167000746a833091b656bfe796c57d667badff691fd4d6a305307166982afdc | c7865981e4755df08eecdeed59af21cb2d09ac90 |
| .github/workflows/scripts-README.md | 8f4fcd5c26992a73270501e64501d2f0d038907e549a4adb6a6bd2dfad0a2869 | 1e5ef49883c2317b4401759c5348a7d88e42a006 |
| .github/workflows/workflow-policy-cases.json | 350937aa600e712a4179d262228e0a85df7375f549e1124a51b23c4b1c311f1a | 731c3bde3ba87efa684eef380e0d99b9297d091c |

Retained exceptions:

- .github/workflows/Generate-StyleGuideArtifacts.ps1: Only independent marked language descriptor; remaining bytes equal source.
- .github/workflows/Test-CiHelpers.test.mjs: 8 exact repository-identity occurrences.
- .github/workflows/Test-StyleGuideArtifacts.ps1: Only independent marked language descriptor; remaining bytes equal source.
- .github/workflows/build.yml: 10 exact repository-identity occurrences. Two verifier role occurrences and one scoped output path.
- .github/workflows/scripts-README.md: Only insert common harness row into accepted TF README; retain every original byte.
