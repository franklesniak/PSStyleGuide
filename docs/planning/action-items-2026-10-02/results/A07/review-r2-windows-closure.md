<!-- markdownlint-disable MD013 -->
# PR227 round2 Windows hash-closure check

**The colorama completeness concern is disproved for the exact pinned closure. No product repair or new selection is needed.** This independently checks the existing [D07-4 hashed Python closure decision](RESULT.md#d07-4-reuse-the-hashed-python-hook-closure), rather than creating a second rubric. Native TF06ad4f7 and current PSc9e0b24 requirements bytes are identical: SHA256 `f9aaac5456d8c076becff82222a49a3a16ef1267de93d347ebcac0fe3a3f5652`.

The old Windows install log only showed packages already satisfied in the existing global interpreter. That result did not prove an empty Windows closure. This check instead created exactly one task-owned Windows x64 Python3.12.10 venv in this scratch directory. Before installation it contained only pip25.0.1, had a distinct sys.prefix/base_prefix and disabled user-site packages. No global or system-site packages were included and colorama was absent.

From the unchanged product root, its private interpreter executed the normal body:

```text
python.exe -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt
```

Actual native exit0, started2026-10-03T11:55:56.158779Z and completed11:56:10.748881Z. All28 pinned packages installed. The only distribution outside those pins is the venv bootstrap pip; colorama remains absent. Actual `python.exe -m pip check` completed0 with “No broken requirements found.” The receipt, log and before/after inventories preserve this result; no retry, weakened hash flag or extra dependency was used.

Click is pinned to8.5.0. [Its exact PyPI release](https://pypi.org/project/click/8.5.0/) supplies the wheel at SHA256 `255bc9599cf7748b4b1a446ccc735421bd08a2ae529a8b88597d3de5664ee360`, the same hash admitted in requirements. Independently downloaded that bounded official wheel, verified its hash, and inspected its complete METADATA: no Requires-Dist entry. Exact installed Click metadata agrees. Its source explicitly records that Colorama is no longer used on Windows beginning8.5.0; the only other colorama source reference is the historical2.0 docstring. [Immutable publisher source](https://github.com/pallets/click/blob/8b19813f2bfca99f1018a587a8cf54fc959f2e5d/src/click/utils.py). No code import of colorama appears in this wheel. Therefore adding colorama based on an older-version assumption would add an unneeded package.

Collected complete primary PyPI Requires-Python/Requires-Dist and release JSON for every one of the28 pinned packages. Captured complete installed wheel METADATA for all28; pip's parsed Requirement forms agree with registry requirements, retaining extra/platform/python markers in both raw forms. Installed versions equal all pins. Optional extras not requested by this closure are not installation obligations. No other missing Windows dependency was found by the actual resolver or installed dependency check. [pip's hash-install contract](https://pip.pypa.io/en/stable/topics/secure-installs/) requires hashes for the selected dependency closure; this successful empty-venv resolution did not rely on existing package satisfaction.

| Evidence | SHA256 |
| --- | --- |
| fresh-windows-install.log | `c64bdd41150c41c266fc049c0e369d4b03bb12c8cdf2f07bd812dcf1f7e55e40` |
| fresh-windows-install-receipt.json | `fb5e618a77e957700bf89e44832fcc8af8061667b36d0d3c78a67c1d5ad8346b` |
| fresh-environment-before.json | `200b2e7124459df061c5f0b86ed4bc4adfc32abfe5a65d6826c407205ecffe25` |
| pinned-dependency-metadata.json | `06db6aa75ded8172f83a16f1db97f836495e0f5c87193e6fe87c6973fa7c4bf1` |
| installed-dependency-metadata.json | `a1e29f4fc49a8db559b1e356a64ee106062476db3c52522aff19436554be9314` |
| click-wheel.METADATA | `e87bce0bd194de70dfb8e708e0a6b0483009f25611804eaf87bfeb63e6c20501` |
| fresh-windows-pip-check.log | `672aec65a45bed50e70229c70934a7eebf0462595c459b83023027645d57cccf` |

All75 product raw identities, index tuples and clean HEADc9e0b24 state remained unchanged around installation; a separate final75-raw guard also passed. No global installation, source/index edit, native operation or suite rerun occurred. The private venv is retained only as task evidence and is not an authored product requirement. The scratch comparison initially rejected insignificant Requires-Dist whitespace; FIXTURE-NOTE.md and the original verifier preserve that tooling failure, with semantic parsed-form comparison used afterward.

Limits: this proves the exact Windows x64 Python3.12.10 default-extras closure today, using authenticated-by-hash wheel artifacts (some downloaded from pip's normal cache). It does not claim every Python3.12 architecture, clean Windows installer provisioning, package-byte runtime attestation, all hook behavior or future registry availability. Prior actual Linux/runtime/hook evidence and current remote CI/review/acceptance gates retain their own scope. Root owns final acceptance and all review clocks/counters; this checked hypothesis introduces no new decision or authority.
