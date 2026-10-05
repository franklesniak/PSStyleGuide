<!-- markdownlint-disable MD013 -->
# R8: fixed unknown-artifact diagnostic — evidenced no change

Review5420961221, comment4189169213, input07636c8633b8544eb30c71ce1b24d2bcdef4c74e. Allegation: include ArtifactId and allowed DestinationMap keys in the unknown-artifact error to improve CI diagnostics.

The private Write-StyleGuideArtifact contract explicitly says parameter binding, destination-map lookup and record-initialization failures occur before ArtifactRecord/Phase wrapping. Its only actual entry-point caller iterates hashtableDestinationMap.Keys and passes that exact dictionary and loop key (generator2194–2206). Source files do not choose arbitrary identifiers or the allowed map. Thus normal current composition cannot reach unknown-artifact with an unexpected ID. The fixed precondition remains appropriate for direct private misuse or a future implementation defect.

The actual outer catch emits only structured fixed result fields and the exception type, not Exception.Message (2231–2253). Adding variable data to this throw would not produce the requested actionable CI message in the current consumer. It would create unchecked detail for direct private callers/debugging and conflict with the selected bounded diagnostic approach. Allowed keys can be inspected at the fixed descriptor/map without printing caller-controlled values. The verifier separately restricts four fixed records and uses only six fixed failure labels; D1/D3 and hostile-field controls retain that contract.

Disposition: current-caller benefit is not substantiated; no product edit. Do not interpolate ArtifactId or DestinationMap values. This is an AGENTS step2 evidence-backed rejection of the proposed remedy, not a claim that all future private callers are correct or that an unknown-ID probe was run. No new interface or logging architecture is selected. Root owns public disposition and attribution.
