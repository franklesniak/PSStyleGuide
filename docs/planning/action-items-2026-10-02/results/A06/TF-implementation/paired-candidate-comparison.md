<!-- markdownlint-disable MD013 -->
# A06 candidate paired comparison

No reverse source repair is indicated by this bounded exact candidate comparison. All shared algorithm/test bytes converge; remaining differences are the approved finite configuration/identity and necessary language-content boundaries.

Accepted PS `98177628b7bc02c646724bfc8aa0fd73fed0cd24` / tree `fd66ed6c5b94d8c012a0aa06c8d30f2ae16746c6` versus committed TF68 candidate `6c0c987799425b60c0e7b76650aa5ec7946811e2` / tree `ced4bb594a121b6c1ead983242ce2967032edd96`. TF68 is not credited as merged or accepted. Root must bind the eventual actual merge and current native refs. This is the25-row task-local comparison, not A18 or final main/main acceptance.

Raw results:8identical paths;9finite mixed-file exceptions;8necessary language-content/absence rows;0unclassified differences. Seven of the12ported workflow files are raw-identical; ci-toolchain.json supplies the eighth equal coupled path. All12coupled TF observations and four generated outputs retain accepted-base bytes.

## Exact per-path identities

Every present entry below is a100644blob. Each row uses the full PS and TF commits above; the JSON repeats each full commit, mode/type, blob, size and SHA256 per side. ABSENT means no tracked path at that exact commit.

| PS path | TF path | PS blob | TF blob | Disposition |
| --- | --- | --- | --- | --- |
| .github/workflows/Classify-InstructionMaintenance.mjs | .github/workflows/Classify-InstructionMaintenance.mjs | d9802a71a9e257bcbd0b9d5055e9f3ed9f430343 | d9802a71a9e257bcbd0b9d5055e9f3ed9f430343 | raw-identical |
| .github/workflows/Classify-InstructionMaintenance.test.mjs | .github/workflows/Classify-InstructionMaintenance.test.mjs | 166d137206aff8f503911be9a569efbd204e023b | 166d137206aff8f503911be9a569efbd204e023b | raw-identical |
| .github/workflows/Generate-StyleGuideArtifacts.ps1 | .github/workflows/Generate-StyleGuideArtifacts.ps1 | 9e52d7482e5105f8c661b1005ba0c76a8e2a939d | ef2e3d08b54212da215790a8a61f4b259b5c81c8 | finite-mixed-file-exception |
| .github/workflows/Test-CiHelpers.test.mjs | .github/workflows/Test-CiHelpers.test.mjs | 2145cb90a7a5a2d292aac7375092dd6b33ea984e | 3a62fde67925bc99285f8a0c3c74b53ac7f7f109 | finite-mixed-file-exception |
| .github/workflows/Test-ExactGitPathSet.ps1 | .github/workflows/Test-ExactGitPathSet.ps1 | 76cad06fd918ac2405981d205814c7e8d85e4dc7 | 76cad06fd918ac2405981d205814c7e8d85e4dc7 | raw-identical |
| .github/workflows/Test-StyleGuideArtifacts.ps1 | .github/workflows/Test-StyleGuideArtifacts.ps1 | 6dc5276d95ac5b161ce28e6ea8eb95f85accfe7f | b3c9ad4caa86919ac1b66c457493f7d6b9d9b813 | finite-mixed-file-exception |
| .github/workflows/Test-StyleGuideGenerator.ps1 | .github/workflows/Test-StyleGuideGenerator.ps1 | dcd0cb93354a74de4a5d8323a7018511323e8bbe | dcd0cb93354a74de4a5d8323a7018511323e8bbe | raw-identical |
| .github/workflows/Validate-WorkflowPolicy.mjs | .github/workflows/Validate-WorkflowPolicy.mjs | b68aa229ae32dae8ad62886e93e161f887f67a26 | b68aa229ae32dae8ad62886e93e161f887f67a26 | raw-identical |
| .github/workflows/Validate-WorkflowPolicy.test.mjs | .github/workflows/Validate-WorkflowPolicy.test.mjs | 3f4bb6c982b584aed1535e9ef04dd918f9069055 | 3f4bb6c982b584aed1535e9ef04dd918f9069055 | raw-identical |
| .github/workflows/build.yml | .github/workflows/build.yml | d46981e38b54e8f8df42158b06ad149ca8c20c45 | c7865981e4755df08eecdeed59af21cb2d09ac90 | finite-mixed-file-exception |
| .github/workflows/scripts-README.md | .github/workflows/scripts-README.md | 8510f350f0247b919b6e1527bcd7b7b7091b103f | 1e5ef49883c2317b4401759c5348a7d88e42a006 | finite-mixed-file-exception |
| .github/workflows/workflow-policy-cases.json | .github/workflows/workflow-policy-cases.json | 731c3bde3ba87efa684eef380e0d99b9297d091c | 731c3bde3ba87efa684eef380e0d99b9297d091c | raw-identical |
| powershell.instructions.md | terraform.instructions.md | b711cec80333e409cb4e644eb94530653ca39109 | 59eeedcfe4cab11ebf87d439d5117f7203b0ea98 | necessary-language-content |
| .github/workflows/workflow-policy-contract.json | .github/workflows/workflow-policy-contract.json | 53d81439e58eb33b95bb1e6f97bc1a124c0b5fac | b7ab4acd91e45652836fe35069dce5268a8e3395 | finite-mixed-file-exception |
| .github/workflows/Test-CheckoutCredentials.ps1 | .github/workflows/Test-CheckoutCredentials.ps1 | 85905890f1eebd304fb8f6613b3e93a67c42043a | 45db9b3fdfa3e85f05d6b567fbaa547d16a8132d | finite-mixed-file-exception |
| .github/workflows/Test-StateRecoveryExamples.mjs | .github/workflows/Test-StateRecoveryExamples.mjs | ABSENT | 0c53093e6a5de264deae9f9269e11c5981d4bdad | necessary-language-content |
| .github/workflows/Test-BlankLineExamples.ps1 | .github/workflows/Test-BlankLineExamples.ps1 | 068c7139a9e6a9276073211f48eca88464204362 | ABSENT | necessary-language-content |
| .github/workflows/ci-toolchain.json | .github/workflows/ci-toolchain.json | 740a7749945acbf53e9981241ea553dc1431d3c8 | 740a7749945acbf53e9981241ea553dc1431d3c8 | raw-identical |
| package.json | package.json | 0421d27aaf9d0facb15b5aa2a214d0757c768358 | dec41f61c36e5770487eb431bd57f2f7dfe62832 | finite-mixed-file-exception |
| .github/workflows/package.json | .github/workflows/package.json | b09ca859508430050dc0b023b3dba62e50748680 | 10078fa5c1f4817a5705188ba61e46a02be41ec4 | finite-mixed-file-exception |
| STYLE_GUIDE.md | STYLE_GUIDE.md | 21bbb515429eb5fdac47f14128a95d5fd55122aa | f872e52ee5b7ded737157dcf745cb93013005a2b | necessary-language-content |
| STYLE_GUIDE_RATIONALE.md | STYLE_GUIDE_RATIONALE.md | afb5ba370810e36a9c1ba103aa8e5691a3131581 | b5efeee6cb8b6ded6099bbee13b6307ea103cc5c | necessary-language-content |
| copilot-instructions.md | copilot-instructions.md | 21bbb515429eb5fdac47f14128a95d5fd55122aa | f872e52ee5b7ded737157dcf745cb93013005a2b | necessary-language-content |
| STYLE_GUIDE_CHAT.md | STYLE_GUIDE_CHAT.md | 556538c7664327652bc42875b63a5bf6bc16783f | a6c4a1aa84cb6c1b0452d3f8d0f071b9a57ba3c8 | necessary-language-content |
| STYLE_GUIDE_FULL.md | STYLE_GUIDE_FULL.md | c06830461f45d089c1f1f2c36d7a7b6472e3d6aa | faaf49ee2bcde0d23da2acd397a73511fe2b6f00 | necessary-language-content |

## Exact exception regions and need

The JSON records the original and replacement bytes for every differing mixed-file line block, with zero-based half-open byte spans and one-based line spans. Equal spans were compared directly. This description does not replace raw equality with normalization.

### .github/workflows/Generate-StyleGuideArtifacts.ps1 -> .github/workflows/Generate-StyleGuideArtifacts.ps1

Marked descriptor only: eleven fixed data fields select scoped ID/path, selector/description/title/anchors/summary placement/composition/standalone append.

Different normative source forms and consumer selectors require these literal values; one identical parser/composition/publication engine plus this finite descriptor suffices.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); results/A06/frontmatter-spacing-decision.md (C98).

PS lines[23, 33] / bytes[586, 1083] -> TF lines[23, 33] / bytes[586, 1246]:

```diff
-    ScopedId = 'powershell-instructions'
-    ScopedPath = 'powershell.instructions.md'
-    Selector = '**/*.ps1'
-    Description = 'PowerShell coding standards'
-    ChatTitle = '# PowerShell Writing Style Guide - Formatted for Copy-Paste Into LLM Chat'
-    GuideAnchor = 'powershell-writing-style'
-    SummaryHeading = 'Executive Summary: Author Profile'
-    SummaryAnchor = 'executive-summary-author-profile'
-    SummaryBefore = ''
-    Composition = 'HeadingLinked'
-    AppendStandalone = $false
+    ScopedId = 'terraform-instructions'
+    ScopedPath = 'terraform.instructions.md'
+    Selector = '**/*.tf,**/*.tfvars,**/*.tftest.hcl,**/*.tf.json,**/*.tftpl,**/*.tfbackend'
+    Description = 'Terraform coding standards: secure, modular, and well-documented infrastructure as code.'
+    ChatTitle = '# Terraform Writing Style Guide - Formatted for Copy-Paste Into LLM Chat'
+    GuideAnchor = 'terraform-writing-style'
+    SummaryHeading = 'Executive Summary: Terraform Philosophy'
+    SummaryAnchor = 'executive-summary-terraform-philosophy'
+    SummaryBefore = 'Terraform Version Requirements'
+    Composition = 'ExplicitBody'
+    AppendStandalone = $true
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/Test-CiHelpers.test.mjs -> .github/workflows/Test-CiHelpers.test.mjs

Eight exact franklesniak/PSStyleGuide to franklesniak/TerraformStyleGuide repository identity substitutions, including negative origin.

Acquisition tests bind the actual repository identity; all test algorithms, both explicit semantic-role fixture loops and16TF modes remain identical.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6).

PS lines[147, 147] / bytes[9003, 9116] -> TF lines[147, 147] / bytes[9003, 9123]:

```diff
-        if ($strMode -eq 'origin-credentials') { 'https://fixture-secret@github.com/franklesniak/PSStyleGuide' }
+        if ($strMode -eq 'origin-credentials') { 'https://fixture-secret@github.com/franklesniak/TerraformStyleGuide' }
```

PS lines[149, 149] / bytes[9203, 9267] -> TF lines[149, 149] / bytes[9210, 9281]:

```diff
-        else { 'https://github.com/franklesniak/PSStyleGuide' }
+        else { 'https://github.com/franklesniak/TerraformStyleGuide' }
```

PS lines[151, 151] / bytes[9273, 9364] -> TF lines[151, 151] / bytes[9287, 9385]:

```diff
-    if ($strMode -eq 'origin-multiple') { 'https://github.com/franklesniak/PSStyleGuide' }
+    if ($strMode -eq 'origin-multiple') { 'https://github.com/franklesniak/TerraformStyleGuide' }
```

PS lines[184, 184] / bytes[11254, 11369] -> TF lines[184, 184] / bytes[11275, 11397]:

```diff
-      GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_SHA: head };
+      GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/TerraformStyleGuide', GITHUB_SHA: head };
```

PS lines[233, 233] / bytes[14530, 14647] -> TF lines[233, 233] / bytes[14558, 14682]:

```diff
-        GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_SHA: head };
+        GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/TerraformStyleGuide', GITHUB_SHA: head };
```

PS lines[392, 392] / bytes[23450, 23568] -> TF lines[392, 392] / bytes[23485, 23610]:

```diff
-if (args.includes('remote') && args.includes('get-url')) console.log('https://github.com/franklesniak/PSStyleGuide');
+if (args.includes('remote') && args.includes('get-url')) console.log('https://github.com/franklesniak/TerraformStyleGuide');
```

PS lines[400, 400] / bytes[24097, 24169] -> TF lines[400, 400] / bytes[24139, 24218]:

```diff
-      GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_SHA: head,
+      GITHUB_REPOSITORY: 'franklesniak/TerraformStyleGuide', GITHUB_SHA: head,
```

PS lines[1469, 1469] / bytes[95693, 95821] -> TF lines[1469, 1469] / bytes[95742, 95877]:

```diff
-    const env = { GITHUB_SHA: event, GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide' };
+    const env = { GITHUB_SHA: event, GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/TerraformStyleGuide' };
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/Test-StyleGuideArtifacts.ps1 -> .github/workflows/Test-StyleGuideArtifacts.ps1

Independent marked descriptor only: ScopedId, ScopedPath, SemanticRole.

The gate must independently authorize the language output and dispatch its actual semantic child. One identical gate plus three fixed values suffices; deriving its allowlist from generator output is not allowed.

Canonical decisions: results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6).

PS lines[37, 39] / bytes[1219, 1346] -> TF lines[37, 39] / bytes[1219, 1343]:

```diff
-    ScopedId = 'powershell-instructions'
-    ScopedPath = 'powershell.instructions.md'
-    SemanticRole = 'PowerShellExamples'
+    ScopedId = 'terraform-instructions'
+    ScopedPath = 'terraform.instructions.md'
+    SemanticRole = 'TerraformRecovery'
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/build.yml -> .github/workflows/build.yml

Ten repository identity substitutions, two verify_generated_artifacts to verify job/dependency occurrences, one powershell.instructions.md to terraform.instructions.md upload path.

Each workflow acquires its own repository, preserves the native required-check context and publishes the correct scoped artifact. All executable acquisition, platform and admission bodies otherwise match.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A03/foundation-dependency-decision.md (C98); results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6).

PS lines[24, 24] / bytes[705, 778] -> TF lines[24, 24] / bytes[705, 785]:

```diff
-              $env:GITHUB_REPOSITORY -cne 'franklesniak/PSStyleGuide') {
+              $env:GITHUB_REPOSITORY -cne 'franklesniak/TerraformStyleGuide') {
```

PS lines[62, 62] / bytes[3095, 3184] -> TF lines[62, 62] / bytes[3102, 3198]:

```diff
-          & $strGitPath remote add origin 'https://github.com/franklesniak/PSStyleGuide'
+          & $strGitPath remote add origin 'https://github.com/franklesniak/TerraformStyleGuide'
```

PS lines[88, 88] / bytes[4809, 4892] -> TF lines[88, 88] / bytes[4823, 4913]:

```diff
-              $arrOrigin[0] -cne 'https://github.com/franklesniak/PSStyleGuide') {
+              $arrOrigin[0] -cne 'https://github.com/franklesniak/TerraformStyleGuide') {
```

PS lines[152, 152] / bytes[8243, 8316] -> TF lines[152, 152] / bytes[8264, 8344]:

```diff
-              $env:GITHUB_REPOSITORY -cne 'franklesniak/PSStyleGuide') {
+              $env:GITHUB_REPOSITORY -cne 'franklesniak/TerraformStyleGuide') {
```

PS lines[190, 190] / bytes[10633, 10722] -> TF lines[190, 190] / bytes[10661, 10757]:

```diff
-          & $strGitPath remote add origin 'https://github.com/franklesniak/PSStyleGuide'
+          & $strGitPath remote add origin 'https://github.com/franklesniak/TerraformStyleGuide'
```

PS lines[216, 216] / bytes[12347, 12430] -> TF lines[216, 216] / bytes[12382, 12472]:

```diff
-              $arrOrigin[0] -cne 'https://github.com/franklesniak/PSStyleGuide') {
+              $arrOrigin[0] -cne 'https://github.com/franklesniak/TerraformStyleGuide') {
```

PS lines[278, 278] / bytes[15679, 15752] -> TF lines[278, 278] / bytes[15721, 15801]:

```diff
-              $env:GITHUB_REPOSITORY -cne 'franklesniak/PSStyleGuide') {
+              $env:GITHUB_REPOSITORY -cne 'franklesniak/TerraformStyleGuide') {
```

PS lines[301, 301] / bytes[17031, 17121] -> TF lines[301, 301] / bytes[17080, 17177]:

```diff
-          & /usr/bin/git remote add origin 'https://github.com/franklesniak/PSStyleGuide'
+          & /usr/bin/git remote add origin 'https://github.com/franklesniak/TerraformStyleGuide'
```

PS lines[347, 347] / bytes[19939, 19969] -> TF lines[347, 347] / bytes[19995, 20005]:

```diff
-  verify_generated_artifacts:
+  verify:
```

PS lines[384, 384] / bytes[21528, 21601] -> TF lines[384, 384] / bytes[21564, 21644]:

```diff
-              $env:GITHUB_REPOSITORY -cne 'franklesniak/PSStyleGuide') {
+              $env:GITHUB_REPOSITORY -cne 'franklesniak/TerraformStyleGuide') {
```

PS lines[407, 407] / bytes[22880, 22970] -> TF lines[407, 407] / bytes[22923, 23020]:

```diff
-          & /usr/bin/git remote add origin 'https://github.com/franklesniak/PSStyleGuide'
+          & /usr/bin/git remote add origin 'https://github.com/franklesniak/TerraformStyleGuide'
```

PS lines[436, 436] / bytes[24487, 24525] -> TF lines[436, 436] / bytes[24537, 24555]:

```diff
-    needs: verify_generated_artifacts
+    needs: verify
```

PS lines[461, 461] / bytes[25429, 25468] -> TF lines[461, 461] / bytes[25459, 25497]:

```diff
-            powershell.instructions.md
+            terraform.instructions.md
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/scripts-README.md -> .github/workflows/scripts-README.md

Four line regions: T1 versus P1 provenance link; semantic-child description; actual semantic-helper table row; native verifier context. Common new-harness row is identical.

Documentation names each live provenance target, semantic child and required check. Identical common prose plus narrow references suffices; copying the whole PS README would remove supported TF guidance.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6); results/A03/foundation-dependency-decision.md (C98).

PS lines[23, 23] / bytes[1511, 1885] -> TF lines[23, 23] / bytes[1511, 1904]:
PS link target: `../../docs/P1-SUPPLY-FREEZE-v1.md#prepare-and-record-on-linuxx64`.

TF link target: `../../docs/T1-SUPPLY-FREEZE-CURRENT-PROVENANCE-v1.md#prepare-and-record-on-linuxx64`. The full original and replacement lines are retained in the JSON evidence.

PS lines[34, 34] / bytes[3722, 3908] -> TF lines[34, 34] / bytes[3741, 3924]:

```diff
-| `Test-StyleGuideArtifacts.ps1` | Runs the blank-line semantic child, generation and committed-artifact checks. | Called by the build workflow; requires its Linux runner environment. |
+| `Test-StyleGuideArtifacts.ps1` | Runs the recovery-example child, generation and committed-artifact checks. | Called by the build workflow; requires its Linux runner environment. |
```

PS lines[36, 36] / bytes[4292, 4512] -> TF lines[36, 36] / bytes[4308, 4461]:

```diff
-| `Test-BlankLineExamples.ps1` | Checks the published PowerShell blank-line examples and their focused mutation controls. | `pwsh -NoLogo -NoProfile -File .github/workflows/Test-BlankLineExamples.ps1` (no parameters). |
+| `Test-StateRecoveryExamples.mjs` | Checks the published Terraform state-recovery examples. | `node .github/workflows/Test-StateRecoveryExamples.mjs` |
```

PS lines[40, 40] / bytes[5073, 5699] -> TF lines[40, 40] / bytes[5022, 5628]:

```diff
-The native required checks keep their existing names. `verify_generated_artifacts` runs deterministic generation and checks the stable result schemas and committed artifacts. `policy` validates the workflow structure, helper selection, and reviewed parser integrity. `markdownlint` runs both existing Markdown lint phases. Candidate instruction tests are separate from the accepted-base maintenance classification. Classification does not grant maintenance authority; the authenticated owner/executor review process still binds scope, current head/base/policy, candidate tests, findings, and independent final quality review.
+The native required checks keep their existing names. `verify` runs deterministic generation and checks the stable result schemas and committed artifacts. `policy` validates the workflow structure, helper selection, and reviewed parser integrity. `markdownlint` runs both existing Markdown lint phases. Candidate instruction tests are separate from the accepted-base maintenance classification. Classification does not grant maintenance authority; the authenticated owner/executor review process still binds scope, current head/base/policy, candidate tests, findings, and independent final quality review.
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### powershell.instructions.md -> terraform.instructions.md

Whole normative language source, rationale, or generated derivative; scoped outputs use named counterpart paths.

PowerShell and Terraform rules/content are intentionally different. The common engine plus fixed language descriptors preserves each actual source and its four generated outputs; identical guide bytes would lose supported language content.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/frontmatter-spacing-decision.md (C98).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### .github/workflows/workflow-policy-contract.json -> .github/workflows/workflow-policy-contract.json

roles.artifactVerifier and one scoped filename inside uploadArtifact.inputs.path.

Retain independent reviewed admission policy and existing native check names/output paths. Shared validator/cases consume this small fixed contract without algorithm divergence.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A03/foundation-dependency-decision.md (C98); results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6).

PS lines[4, 4] / bytes[67, 120] -> TF lines[4, 4] / bytes[67, 100]:

```diff
-    "artifactVerifier": "verify_generated_artifacts"
+    "artifactVerifier": "verify"
```

PS lines[34, 34] / bytes[1192, 1307] -> TF lines[34, 34] / bytes[1172, 1286]:

```diff
-        "path": "copilot-instructions.md\npowershell.instructions.md\nSTYLE_GUIDE_CHAT.md\nSTYLE_GUIDE_FULL.md\n",
+        "path": "copilot-instructions.md\nterraform.instructions.md\nSTYLE_GUIDE_CHAT.md\nSTYLE_GUIDE_FULL.md\n",
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/Test-CheckoutCredentials.ps1 -> .github/workflows/Test-CheckoutCredentials.ps1

One exact HTTPS origin literal.

Anonymous checkout must bind to the repository being validated; one common checker plus its exact origin literal suffices.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes).

PS lines[40, 40] / bytes[1958, 2035] -> TF lines[40, 40] / bytes[1958, 2042]:

```diff
-if ($arrRemoteUrls[0] -cne 'https://github.com/franklesniak/PSStyleGuide') {
+if ($arrRemoteUrls[0] -cne 'https://github.com/franklesniak/TerraformStyleGuide') {
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/Test-StateRecoveryExamples.mjs -> .github/workflows/Test-StateRecoveryExamples.mjs

Whole necessary language-only semantic helper; absent in the other repository. These are not renamed equivalents.

The actual PS blank-line and TF state-recovery examples require distinct executable semantic oracles; the common gate selects their fixed roles without copying an irrelevant helper.

Canonical decisions: results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### .github/workflows/Test-BlankLineExamples.ps1 -> .github/workflows/Test-BlankLineExamples.ps1

Whole necessary language-only semantic helper; absent in the other repository. These are not renamed equivalents.

The actual PS blank-line and TF state-recovery examples require distinct executable semantic oracles; the common gate selects their fixed roles without copying an irrelevant helper.

Canonical decisions: results/A06/design.md#finding-a06-d3-share-the-artifact-gate-without-losing-semantic-admission (C96.6); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### package.json -> package.json

Root: name, description and repository.url. Workflow package: name, repository.url, first keyword, author, bugs.url and homepage. Exact applicable fields are in per-path regions.

Package ownership/language metadata differs; runtime versions, dependency declarations and scripts are unchanged common operational fields.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes).

PS lines[2, 2] / bytes[2, 45] -> TF lines[2, 2] / bytes[2, 52]:

```diff
-  "name": "psstyleguide-agent-governance",
+  "name": "terraformstyleguide-agent-governance",
```

PS lines[5, 5] / bytes[86, 159] -> TF lines[5, 5] / bytes[93, 173]:

```diff
-  "description": "Locked agent-governance validation for PSStyleGuide.",
+  "description": "Locked agent-governance validation for TerraformStyleGuide.",
```

PS lines[20, 20] / bytes[688, 754] -> TF lines[20, 20] / bytes[702, 775]:

```diff
-    "url": "git+https://github.com/franklesniak/PSStyleGuide.git"
+    "url": "git+https://github.com/franklesniak/TerraformStyleGuide.git"
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### .github/workflows/package.json -> .github/workflows/package.json

Root: name, description and repository.url. Workflow package: name, repository.url, first keyword, author, bugs.url and homepage. Exact applicable fields are in per-path regions.

Package ownership/language metadata differs; runtime versions, dependency declarations and scripts are unchanged common operational fields.

Canonical decisions: LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes).

PS lines[2, 2] / bytes[2, 28] -> TF lines[2, 2] / bytes[2, 35]:

```diff
-  "name": "psstyleguide",
+  "name": "terraformstyleguide",
```

PS lines[13, 13] / bytes[310, 376] -> TF lines[13, 13] / bytes[317, 390]:

```diff
-    "url": "git+https://github.com/franklesniak/PSStyleGuide.git"
+    "url": "git+https://github.com/franklesniak/TerraformStyleGuide.git"
```

PS lines[16, 16] / bytes[397, 415] -> TF lines[16, 16] / bytes[411, 428]:

```diff
-    "powershell",
+    "terraform",
```

PS lines[20, 20] / bytes[462, 491] -> TF lines[20, 20] / bytes[475, 535]:

```diff
-  "author": "Frank Lesniak",
+  "author": "Frank Lesniak, Blake Cherry, and Danny Stutz",
```

PS lines[23, 23] / bytes[523, 588] -> TF lines[23, 23] / bytes[567, 639]:

```diff
-    "url": "https://github.com/franklesniak/PSStyleGuide/issues"
+    "url": "https://github.com/franklesniak/TerraformStyleGuide/issues"
```

PS lines[25, 25] / bytes[593, 662] -> TF lines[25, 25] / bytes[644, 720]:

```diff
-  "homepage": "https://github.com/franklesniak/PSStyleGuide#readme",
+  "homepage": "https://github.com/franklesniak/TerraformStyleGuide#readme",
```

Evidence: Immutable raw blob comparison; root-port-verification.json for delivered paths; accepted-base identity for coupled paths.

### STYLE_GUIDE.md -> STYLE_GUIDE.md

Whole normative language source, rationale, or generated derivative; scoped outputs use named counterpart paths.

PowerShell and Terraform rules/content are intentionally different. The common engine plus fixed language descriptors preserves each actual source and its four generated outputs; identical guide bytes would lose supported language content.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/frontmatter-spacing-decision.md (C98).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### STYLE_GUIDE_RATIONALE.md -> STYLE_GUIDE_RATIONALE.md

Whole normative language source, rationale, or generated derivative; scoped outputs use named counterpart paths.

PowerShell and Terraform rules/content are intentionally different. The common engine plus fixed language descriptors preserves each actual source and its four generated outputs; identical guide bytes would lose supported language content.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/frontmatter-spacing-decision.md (C98).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### copilot-instructions.md -> copilot-instructions.md

Whole normative language source, rationale, or generated derivative; scoped outputs use named counterpart paths.

PowerShell and Terraform rules/content are intentionally different. The common engine plus fixed language descriptors preserves each actual source and its four generated outputs; identical guide bytes would lose supported language content.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/frontmatter-spacing-decision.md (C98).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### STYLE_GUIDE_CHAT.md -> STYLE_GUIDE_CHAT.md

Whole normative language source, rationale, or generated derivative; scoped outputs use named counterpart paths.

PowerShell and Terraform rules/content are intentionally different. The common engine plus fixed language descriptors preserves each actual source and its four generated outputs; identical guide bytes would lose supported language content.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/frontmatter-spacing-decision.md (C98).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

### STYLE_GUIDE_FULL.md -> STYLE_GUIDE_FULL.md

Whole normative language source, rationale, or generated derivative; scoped outputs use named counterpart paths.

PowerShell and Terraform rules/content are intentionally different. The common engine plus fixed language descriptors preserves each actual source and its four generated outputs; identical guide bytes would lose supported language content.

Canonical decisions: results/A06/design.md#finding-a06-d1-converge-composition-without-losing-language-content (C96); LOOP-POLICY.md#exact-byte-comparison-and-necessary-exceptions (D07 approved classes); results/A06/frontmatter-spacing-decision.md (C98).

Whole file as identified by raw blob/bytes; absent counterpart recorded explicitly.

Evidence: Raw Git object and accepted-TF-base preservation; Root current TF semantic/golden/hosted evidence; no new test execution.

## Preserved outputs and existing validation

| TF output | Blob | SHA256 |
| --- | --- | --- |
| copilot-instructions.md | f872e52ee5b7ded737157dcf745cb93013005a2b | 4a2f457d7334cb45e21f6e50a7973e10e765b05832487a2db0d2a229f7eef11e |
| terraform.instructions.md | 59eeedcfe4cab11ebf87d439d5117f7203b0ea98 | be0e3b5ea03de9d1963014dabcc3cf82c6400f2239cceb5474125c4f8ecfb38a |
| STYLE_GUIDE_CHAT.md | a6c4a1aa84cb6c1b0452d3f8d0f071b9a57ba3c8 | 190179ef082085f8919cd2a265a683ffa103cdd000c12725f3a8a464235e4f72 |
| STYLE_GUIDE_FULL.md | faaf49ee2bcde0d23da2acd397a73511fe2b6f00 | 9e9a86ecb5e748c78629cfcc2514dadbd9dd3b90ba2e62dbf522e77ce8db5fab |

All four raw candidate outputs equal accepted TFe21b74f and the existing actual TF generator two-pass golden results. Existing final-binding evidence credits567Node tests/zero failures or skips,11hooks and exact-input guard; hosted candidate push and same-tree PR proof each passed156assertions twice on Windows5.1, Windows7 and native-ext4Linux7, with same-revision artifact admission/publication. No test was rerun for this comparison. Those candidate results do not establish landed acceptance.

## Remaining work

- TF68 remote review/current ordinary CI, normal merge and actual landed acceptance; root must rebind this table to actual merge commit/tree and fresh native refs.
- A06 actual future recovery/new-harness and Node22 caller integration plus affected integrity tests remain; generator platform proof is not recovery proof.
- A03 R5/B1 credential/schema consumers and later TF D2 jobs/policy/cases/publication wiring remain.
- A07 R5/B1 independently usable runtime/acquisition qualification and coordinated consumers remain prerequisites; later actual recovery runtime/platform cells remain.
- A21 later actual seven-loader closure and recovery admission integration remain; this batch covers only the finite generator-harness selector/test.
- A16 Gate A real same-revision recovery platform proof, zero-mutation requirements and real operator plus independent-peer approval remain; A17 Gate B and its fresh applicable human approvals remain.
- A14/issue155 named live-filesystem residuals remain; this comparison establishes no hostile competing-writer guarantee.
- A18 full tracked union/capability/exception audit and A19 issue/all402disposition closure remain.

Replacement-disabled and no-optional-locks immutable ls-tree/cat-file/rev-parse reads. Compare raw bytes and modes/types first; line/byte regions only describe actual differences. No normalization, tests, native calls, product/index/ref/config/planning writes or descendants.
