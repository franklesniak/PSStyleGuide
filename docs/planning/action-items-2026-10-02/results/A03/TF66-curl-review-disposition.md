<!-- markdownlint-disable MD013 -->
# TF66 R4: retain the valid curl configuration-isolation flag

Validation result: false positive; no product change. [Copilot comment4178540628](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4178540628) says curl has no `--disable` option. The exact reviewed input is `e2f0652654ef0954e17fc3a255b87375908d0521`, review5407265563, with observed effort Lite.

The [official curl manual](https://curl.se/docs/manpage.html#disable) documents `--disable` as the long form of `-q`. When it is the first argument, curl does not read its default curlrc configuration. The actual setup command puts this option first, followed by the existing HTTPS restrictions, bounded retry/timeout options and output path. Removing it would lose the intended ambient-configuration isolation.

Actual Ubuntu hosted setup run37217666597/job111481387287 on this exact head completed the Node-runtime acquisition step successfully at2026-10-04T16:41:10Z. Its full log includes the exact command and has SHA256 `7d64f1a1c893abcd628e443f66e74ef85799aaed41ae93259c0f3471101b940a`. Root read the authenticated job/step result and command. This is direct evidence against the claimed unknown-option failure.

A separate local check ran `C:/Windows/System32/curl.exe --disable --version`, returned0 and identified curl8.21.0. Its log SHA256 is `462db4e956d97703eae92a1863090a26987ab7b9bc55c43b4e11565918cc56a4`. This local check proves option acceptance, not a download; the hosted result supplies the actual acquisition evidence. [The bounded receipt](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/round1-root-evidence/R4-curl-validation.json) retains both results.

Keep `--disable` as the first curl argument. Retain all existing transport and timeout controls. No alternative design or new rubric is needed because validation disproved the alleged defect and identified no material improvement. The root will post one bounded evidence reply and resolve the thread during the recorded round disposition. This record does not itself claim that a native reply or resolution occurred.
