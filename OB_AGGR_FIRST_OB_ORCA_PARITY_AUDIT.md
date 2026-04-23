# OB -> ORCA AGGR_FIRST Parity Audit

## Scope
This document is the current acceptance baseline for OB->ORCA AGGR_FIRST parity in the current implementation cycle.

Status labels:
- `Done`: implemented and validated with evidence.
- `N-A`: intentionally not applicable in GP/ORCA architecture.

## Final Status Matrix
| Area | Status | Primary Evidence | Validation Evidence |
| --- | --- | --- | --- |
| Null-propagation gate on aggregate arguments | Done | `BF-002` | `aggr_first_rewriter.sql` matrix |
| Null-reject gating for unsafe aggregate args | Done | `BF-005` | `aggr_first_rewriter.sql` matrix |
| Strict-wrapper null-reject propagation | Done | `BF-006` | `aggr_first_rewriter.sql` matrix |
| Composite boolean null-reject migration | Done | `BF-006` | `aggr_first_rewriter.sql` matrix |
| Supported aggregate whitelist (`COUNT/SUM/MIN/MAX/AVG`) | Done | `BF-003`, `BF-009` | `aggr_first_rewriter.sql` matrix |
| Runtime gain signal beyond plan-shape parity | Done | `BF-011` | `cs7` probe v2 (2026-04-23) |
| Extended AVG/composite-boolean edge cases | Done | `BF-012` | expected files refreshed on `cs7` (2026-04-23) |
| Non-adaptable OB assumptions inventory | Done | `NA-001..NA-003` | rationale table below |

## Evidence Index
| ID | Description | Status | Code / Artifact |
| --- | --- | --- | --- |
| BF-001 | Candidate state model | Done | `CSubqueryHandler.h` `SAggrFirstAnalysis` |
| BF-002 | Non-COUNT arg null-propagation gate | Done | `CSubqueryHandler.cpp` `FNullPropagateAggArg` |
| BF-003 | Aggregate family gate | Done | `CSubqueryHandler.cpp` `FIsSupportedAggrFirstAgg` |
| BF-004 | Unsafe arg fallback guard | Done | `CSubqueryHandler.cpp` `SSubqueryDesc::SetCorrelatedExecution` |
| BF-005 | Null-reject context relaxation | Done | `CSubqueryHandler.cpp` `AnalyzeAggrFirstCandidate` |
| BF-006 | Boolean null-reject propagation | Done | `CSubqueryHandler.cpp` `FIsNullRejectConditionForSubquery` |
| BF-007 | INDF/equality-like delayability | Done | `CDecorrelator.cpp` `FNullSafeEqualityLike`, `FDelayable` |
| BF-008 | Fallback COUNT semantics check (separate planner path) | Done | `cs7` targeted validation block `Q1..Q12` |
| BF-009 | AVG whitelist landing | Done | `CSubqueryHandler.cpp` `FIsSupportedAggrFirstAgg` + AVG matrix rows |
| BF-010 | OB non-adaptable assumptions set | Done | `NA-001..NA-003` |
| BF-011 | Runtime benefit probe | Done | `cs7` probe v1+v2 |
| BF-012 | AVG/composite-boolean edge-case extension | Done | `aggr_first_rewriter.sql` + expected files |

## Runtime Evidence (BF-011)
### v1 (historical baseline)
- Query: correlated AVG with `not ((subquery) <= 0)` shape.
- Observation: rowcount parity held, but no runtime gain in that setup.
- Purpose: baseline datapoint before direct enhancement toggle verification.

### v2 (current acceptance, 2026-04-23 on `cs7`)
- Probe artifact: `/tmp/aggr_first_runtime_probe_v2.out`.
- Toggle visibility: `optimizer_enable_aggr_first_orca_enhancement` is visible and mutable.
- Data volume: `o=20,000`, `i=40,000`.
- Rowcount parity: `9286` for both `on/off`.
- Enhancement `on`:
  - Plan shape: pre-aggregated join path (no per-row scalar subplan loops).
  - Runtime: `Execution time: 284.670 ms`; repeats `266.422 / 267.676 / 274.597 ms`.
- Enhancement `off`:
  - Plan shape: scalar `SubPlan` with aggregate loops per outer row (`loops=20000`).
  - Runtime: `Execution time: 36058.648 ms`; repeats `33807.257 / 33666.575 / 33745.691 ms`.

Conclusion: runtime gain is confirmed for the profiled query shape in the current `cs7` environment with correctness parity.

Scope note: runtime figures are workload/environment specific and should not be generalized to all query patterns without additional profiling.

## OB Non-Adaptable Assumptions
| ID | Assumption | Status | Rationale |
| --- | --- | --- | --- |
| NA-001 | OB internal function/control-flow names map 1:1 to ORCA symbols | N-A | ORCA parity is semantic/behavioral, not symbol-name identity |
| NA-002 | Fallback planner rewrites are part of ORCA parity surface | N-A | Fallback (`cdbsubselect`) and ORCA xform paths are distinct |
| NA-003 | Physical operator tree should match OB exactly | N-A | Acceptance is correctness + intended plan-shape direction, not identical physical trees |

## Current Closure
- ORCA code, targeted regression tests, and parity evidence are complete for the current slice.
- If new ORCA code lands, rerun `aggr_first_rewriter.sql` and refresh this audit by delta only.
