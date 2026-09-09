# Marty: Cargo and Docker integration validation

Measured on 9 September 2026. This fork follows the [adorsys status-list-server integration](https://github.com/boringcache/status-list-server/tree/refs/heads/boringcache-validation): a repository-owned `.boringcache.toml` plan, thin One workflow steps, OIDC authentication, trusted writers and read-only consumers.

The runs use released One/CLI 1.30.1 and sccache 0.17.0. One is pinned to `404b744a2053da4cf963f13f615f7fafe94f3cf7`. No unreleased CLI changes were used. Whole-job times exclude queue time; One elapsed includes its own cache operations and wrapped command. These timing boundaries must not be mixed.

The `.boringcache.toml` Cargo profile combines registry cache/index, Git dependency objects, a typed Cargo target archive and sccache. The native `ci.yml` platform jobs use `mode: cargo` for the existing nextest command, then `boringcache cargo` for doctests, bindings and the ZKP tests. Other CI jobs retain their existing behavior.

In the matched dedicated run at `46e0e98e9982eb8af638eb15ea0f384560d611cf`, One Cargo elapsed fell from 582.4 s to 202.1 s. Cargo's compilation phase fell from 282 s to 0.45 s. Both jobs ran 1,400 selected tests successfully, with four skipped. Test execution itself took 92.464 s in the seed and 124.869 s warm; target reuse does not make test execution free. Warm doctest preparation took 0.38 s.

The warm native statistics contain zero executed compiles and three non-cacheable compiler probes. This demonstrates target reuse; it is not a 100% sccache hit-rate measurement. Warm cache/read/write errors and timeouts were zero. The seed had one unattributed native `cache_errors` event, with zero read errors, write errors and timeouts. Archive publication contributed substantial seed overhead, so target archive cost must remain in the reported timing boundary.

A [canceled native CI attempt](https://github.com/boringcache/marty-core/actions/runs/34363252195) overlapped part of the seed. It is excluded from successful-run counts and does not establish a clean cold compiler-backend comparison. The subsequent [native CI validation](https://github.com/boringcache/marty-core/actions/runs/34364157847) at `2e3923c24aa79966a1d27d59c4093e45a1523101` is assessed separately from the dedicated matched timing pair.

Native CI passed all 17 applicable jobs, with the pull-request-only affected-test job skipped. The CI gate passed. The three migrated platform jobs took 631 s on Linux, 1,024 s on macOS and 2,069 s on Windows. These are successful native integrations, not matched platform speed comparisons. Each platform retains workspace tests, doctests, bindings and ZKP tests; the security, feature, Python and WASM checks also passed.


## Evidence and limits

The [full integration measurements](boringcache-full-measurements.json) retain workflow and job URLs, exact configuration SHAs, step timings, native tool statistics and relevant log observations. Failed and canceled attempts remain in the evidence. Successful job status alone is not treated as proof of complete cache reuse or zero cache errors.

The earlier [compiler/archive comparison](https://github.com/boringcache/marty-core/blob/compiler-cache-validation/.github/boringcache-validation.md) starts at the captured upstream HEAD~5 and tests five real first-parent changes. It is a separate cohort and must not be relabeled as full Cargo/Docker measurements. Its historical workflows should be dispatched from `compiler-cache-validation`; their strict source-equality checks intentionally reject later integration changes. The captured source window remains in `boringcache-source-window.json` beside this report.

These observations do not establish long-term retention, eviction resilience, unique-storage or cost savings, or a matched full-pipeline speed improvement over upstream. No upstream pull request, GitHub comment or outreach message was sent by this validation task.
