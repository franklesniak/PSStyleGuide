<!-- markdownlint-disable MD013 -->
# Final Windows focused evidence

All six product groups pass on PS staged treea716a1f8: three-file parser/PSSA with no findings; R8 byte contracts and original negative; persistent conversion/reuse; setup-reader controls; four selected CI tests; patched dependency callers; and PS blank-line semantics (analysis/R8 form one group). Exact completed groups and results are bound in ROOT-FINAL-VERIFICATION.json. Python3.12.10, PowerShell7.6.5, Node24.18.1/npm11.16.0 and PSSA1.24 were used.

This is combined evidence from preserved runs. The first failed before product groups on npm cache placement. The next ran four groups successfully but its summary parser contained a corrupted Unicode marker. An explicit owned cache and UTF-8 receipt correction allowed a final continuation to verify the saved receipts and execute only dependency/blank-line groups. All12 meaningful receipt negatives reject. Both earlier runs remain failed; no passed native group was rerun. All owned jobs ended empty and source/dependency/Git guards match.

Unchanged external converter, clock and setup controls retain their exact source/runtime reuse limits in reuse-table.json. Actual destination fullSelfTest is covered by the separate Linux aggregate. Normal commit, actual B/H/finalization/current audit, final quality, remote reviews/current CI and legitimate dedicated activation remain pending.
