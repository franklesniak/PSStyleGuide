# Private endpoint runner correction

The first preparation guard stopped on a receipt-field name before checkout or product commands.
The actual retained field is dependency_files. Use that field; keep all guards and commands unchanged.
The original failed run is retained. Its fixture is still clean at d7, and no product test was started.
