# marty-core: BoringCache validation

Completed 9 September 2026. Fork-only validation; no outreach, upstream PR or comment was sent.

The managed compiler store is a strong technical fit for the open shared-cache requirement. Five separately namespaced cold/warm pairs per provider supply five samples per phase. The pairs ran concurrently; GitHub seeds recorded substantial native write failures, so their timing cohort is not a clean comparison against a fully populated backend. Native read-only warm write denials are distinct from remote failures. See the separate native diagnostic evidence for the isolated follow-up. This pilot does not establish BYOC S3/R2 support, cross-branch trust enforcement, budget or purchasing authority.

## Measured workloads

Timings measure the selected build command, including nextest execution. Cold/warm values are medians of five samples per phase and provider. Rolling values are the median and range across five different upstream revisions. Queue time, setup, cache restoration and post-job saving are outside the workload timer; these steps are available in the JSON evidence.

| Workload | Provider | Cold | Fresh-runner warm | Five rolling changes: median (range) |
| --- | --- | ---: | ---: | ---: |
| workspace | BoringCache | 472.4 | 238.5 | 253.2 (248.7–347.2) |
| workspace | GitHub | 486.5 | 421.4 | 346.0 (310.1–621.5) |

Qualification source: [upstream request](https://github.com/ElevenID/.github/issues/21).

Ubuntu 24.04, Rust 1.97.1 and cargo-nextest 0.9.143. The selected workspace nextest suite uses test-fixtures and excludes marty-zkp and marty-bindings, followed by doctests. The five rolling revisions passed 1,281, 1,354, 1,362, 1,400 and 1,400 nextest tests respectively, with four skipped each. This is not the entire upstream CI matrix. The isolated GitHub diagnostic confirmed 1,159 HTTP 429 cache-write failures with one seed job active.

## Source and integration

The captured source window starts at `0cfef3337e9a47288e90e325b495d050c07f70e2` (captured upstream head ~5) and ends at `14a6b356811c27d0df9115fe9cc6df6b2a21952b`. Every adjacent first-parent patch was applied in order. Each job checks source equality against `.github/boringcache-source`, excluding only the validation harness.

The paired jobs use the same source, runner class, toolchain and cache surface. BoringCache One is pinned to `404b744a2053da4cf963f13f615f7fafe94f3cf7` (v1.30.1); actual CLI versions are retained. Authentication uses GitHub OIDC, with no static cache token. Cold and rolling jobs may publish; warm jobs restore only. Rust jobs use sccache 0.17.0 for both providers and no target/package cache. The cc crate can also use the Rust wrapper for native dependencies; Rust counts are reported separately.

| Change | Upstream revision | Subject |
| ---: | --- | --- |
| 1 | [39f605a48be7](https://github.com/ElevenID/marty-core/commit/39f605a48be7572d31b4afcb7de3bcac48895041) | breaking(security): remove OID4VCI local issuer feature (#314) |
| 2 | [f4c390f70ab0](https://github.com/ElevenID/marty-core/commit/f4c390f70ab016df6cb21234389021be9debf303) | breaking(security): remove production local crypto APIs (#315) |
| 3 | [b3c6b6156386](https://github.com/ElevenID/marty-core/commit/b3c6b61563866528eb1a4f5469dd29af00500113) | Enforce KMS-only crypto boundaries and bounded verification (#317) |
| 4 | [1ae5b71e53eb](https://github.com/ElevenID/marty-core/commit/1ae5b71e53ebfd2bad29b2e7c23c3d048461245c) | security: enforce KMS-only crypto boundaries and audited fork pins (#318) |
| 5 | [14a6b356811c](https://github.com/ElevenID/marty-core/commit/14a6b356811c27d0df9115fe9cc6df6b2a21952b) | docs(crypto): record final audit integration (#319) |

## Separate native diagnostics

These runs are excluded from the timing table above. Library attribution includes only workspace library targets. Native write-error counters do not alone identify a remote service failure.

| Experiment | Workload / phase | Workspace library lookups | Read-only write denials | Other write errors | Evidence |
| --- | --- | --- | ---: | ---: | --- |
| marty_isolated_github | workspace / cold | 9 libraries; 0 hits / 9 misses (per-library data in JSON) | 0 | 1159 | [job](https://github.com/boringcache/marty-core/actions/runs/34357852180/job/102486978595) |
| marty_isolated_github | workspace / warm | 9 libraries; 3 hits / 6 misses (per-library data in JSON) | 1178 | 0 | [job](https://github.com/boringcache/marty-core/actions/runs/34357852180/job/102489569933) |

## Per-job evidence

[Measurements](boringcache-measurements.json) retain source hashes, timings, commands, test outcomes, native counters and final job links. [Source window](boringcache-source-window.json) retains the original revisions and changed paths. Actions artifacts have a 30-day retention setting; these committed summaries do not depend on artifact retention.

| Source index | Case / phase | Provider | Workload seconds | Job |
| ---: | --- | --- | ---: | --- |
| 0 | workspace / cold | GitHub | 455.345 | [job 102467198695](https://github.com/boringcache/marty-core/actions/runs/34351971662/job/102467198695) |
| 0 | workspace / cold | BoringCache | 368.499 | [job 102467199088](https://github.com/boringcache/marty-core/actions/runs/34351971662/job/102467199088) |
| 0 | workspace / warm | BoringCache | 232.559 | [job 102469905519](https://github.com/boringcache/marty-core/actions/runs/34351971662/job/102469905519) |
| 0 | workspace / warm | GitHub | 439.984 | [job 102469905704](https://github.com/boringcache/marty-core/actions/runs/34351971662/job/102469905704) |
| 0 | workspace / cold | GitHub | 493.280 | [job 102467474058](https://github.com/boringcache/marty-core/actions/runs/34352051746/job/102467474058) |
| 0 | workspace / cold | BoringCache | 486.641 | [job 102467474315](https://github.com/boringcache/marty-core/actions/runs/34352051746/job/102467474315) |
| 0 | workspace / warm | GitHub | 442.164 | [job 102470397657](https://github.com/boringcache/marty-core/actions/runs/34352051746/job/102470397657) |
| 0 | workspace / warm | BoringCache | 246.237 | [job 102470397669](https://github.com/boringcache/marty-core/actions/runs/34352051746/job/102470397669) |
| 0 | workspace / cold | BoringCache | 472.435 | [job 102467480065](https://github.com/boringcache/marty-core/actions/runs/34352053564/job/102467480065) |
| 0 | workspace / cold | GitHub | 393.841 | [job 102467480374](https://github.com/boringcache/marty-core/actions/runs/34352053564/job/102467480374) |
| 0 | workspace / warm | BoringCache | 178.894 | [job 102470259288](https://github.com/boringcache/marty-core/actions/runs/34352053564/job/102470259288) |
| 0 | workspace / warm | GitHub | 412.090 | [job 102470259936](https://github.com/boringcache/marty-core/actions/runs/34352053564/job/102470259936) |
| 0 | workspace / cold | BoringCache | 360.330 | [job 102467487935](https://github.com/boringcache/marty-core/actions/runs/34352055461/job/102467487935) |
| 0 | workspace / cold | GitHub | 510.324 | [job 102467488220](https://github.com/boringcache/marty-core/actions/runs/34352055461/job/102467488220) |
| 0 | workspace / warm | BoringCache | 238.530 | [job 102470530675](https://github.com/boringcache/marty-core/actions/runs/34352055461/job/102470530675) |
| 0 | workspace / warm | GitHub | 410.224 | [job 102470530692](https://github.com/boringcache/marty-core/actions/runs/34352055461/job/102470530692) |
| 0 | workspace / cold | BoringCache | 478.396 | [job 102467494441](https://github.com/boringcache/marty-core/actions/runs/34352057302/job/102467494441) |
| 0 | workspace / cold | GitHub | 486.511 | [job 102467494680](https://github.com/boringcache/marty-core/actions/runs/34352057302/job/102467494680) |
| 0 | workspace / warm | BoringCache | 244.473 | [job 102470372374](https://github.com/boringcache/marty-core/actions/runs/34352057302/job/102470372374) |
| 0 | workspace / warm | GitHub | 421.380 | [job 102470372407](https://github.com/boringcache/marty-core/actions/runs/34352057302/job/102470372407) |
| 1 | workspace / commit | GitHub | 621.537 | [job 102472745576](https://github.com/boringcache/marty-core/actions/runs/34353642438/job/102472745576) |
| 1 | workspace / commit | BoringCache | 248.671 | [job 102472745757](https://github.com/boringcache/marty-core/actions/runs/34353642438/job/102472745757) |
| 2 | workspace / commit | BoringCache | 253.221 | [job 102476635515](https://github.com/boringcache/marty-core/actions/runs/34354798211/job/102476635515) |
| 2 | workspace / commit | GitHub | 345.999 | [job 102476635784](https://github.com/boringcache/marty-core/actions/runs/34354798211/job/102476635784) |
| 3 | workspace / commit | GitHub | 310.089 | [job 102478986876](https://github.com/boringcache/marty-core/actions/runs/34355492202/job/102478986876) |
| 3 | workspace / commit | BoringCache | 272.785 | [job 102478987289](https://github.com/boringcache/marty-core/actions/runs/34355492202/job/102478987289) |
| 4 | workspace / commit | GitHub | 435.957 | [job 102481116216](https://github.com/boringcache/marty-core/actions/runs/34356121331/job/102481116216) |
| 4 | workspace / commit | BoringCache | 347.191 | [job 102481116741](https://github.com/boringcache/marty-core/actions/runs/34356121331/job/102481116741) |
| 5 | workspace / commit | GitHub | 311.110 | [job 102484163885](https://github.com/boringcache/marty-core/actions/runs/34357016445/job/102484163885) |
| 5 | workspace / commit | BoringCache | 252.421 | [job 102484164352](https://github.com/boringcache/marty-core/actions/runs/34357016445/job/102484164352) |
