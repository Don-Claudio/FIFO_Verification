# Synchronous FIFO — Coverage Model

Maps each feature in docs/verification_plan.md to a concrete coverage
construct. This model measures whether a scenario was *exercised*, not
whether the DUT responded correctly — correctness is the responsibility
of the scoreboard (reference-model comparison) and assertions, not this
document.

Occupancy (how many entries the FIFO currently holds) is tracked in the
testbench by counting accepted writes/reads observed on the interface —
not by reading the DUT's internal `count` register directly. This keeps
verification black-box: we only trust what the DUT exposes at its pins.

---

## 1. Covergroup: cg_write_read_ops
*Sampled every clock edge. Covers IF-1 through IF-5.*

| Plan ID | Coverpoint / Bin                              | Notes |
|---------|-------------------------------------------------|-------|
| IF-1    | cross cp_w_enb=1, cp_r_enb=0                     | write only |
| IF-2    | cross cp_w_enb=0, cp_r_enb=1                     | read only |
| IF-3    | cross cp_w_enb=0, cp_r_enb=0                     | neither |
| IF-4    | cross cp_w_enb=1, cp_r_enb=1                     | simultaneous |
| IF-5    | cp_din: bins zero={0}, all_ones={'1}, others=default | full data range |

## 2. Covergroup: cg_reset
*Sampled on reset assertion, driven by directed tests. Covers IF-6, IF-7.*

| Plan ID | Coverpoint / Bin                                     | Notes |
|---------|--------------------------------------------------------|-------|
| IF-6    | cp_reset_timing: bins mid_cycle, aligned_to_edge         | testbench flags which case a directed test drove |
| IF-7    | cross cp_reset_timing, cp_w_enb, cp_r_enb                | reset while w/r also asserted |

## 3. Covergroup: cg_flag_transitions
*Sampled every clock edge. Covers FN-4, FN-5, FN-6 (occurrence only — correctness checked by scoreboard).*

| Plan ID | Coverpoint / Bin                                    | Notes |
|---------|--------------------------------------------------------|-------|
| FN-4    | cp_full_transition: bins (0=>1), (1=>0) on `full`       | did full ever assert and de-assert |
| FN-5    | cp_empty_transition: bins (0=>1), (1=>0) on `empty`      | did empty ever assert and de-assert |
| FN-6    | cp_post_reset: bins empty_after_reset                   | sampled one cycle after reset de-asserts |

**FN-1, FN-2, FN-3 (ordering, no loss, no duplication)** — no coverpoint.
These are checked continuously by the scoreboard comparing every `dout`
against a reference queue. Coverage of *how much* stimulus exercised
this is implicitly covered by cg_write_read_ops and cg_occupancy
running long enough — there's no separate "ordering bin" to hit.

## 4. Covergroup: cg_occupancy
*Sampled every clock edge. Tracks FIFO occupancy (testbench-maintained counter). Covers AR-1 through AR-4.*

| Plan ID | Coverpoint / Bin                                              | Notes |
|---------|-------------------------------------------------------------------|-------|
| —       | cp_occupancy: bins empty={0}, one={1}, mid={2:Depth-2}, near_full={Depth-1}, full={Depth} | base coverpoint, everything below crosses it |
| AR-1    | cross cp_occupancy=full, cp_w_enb=1                                | write attempted while full |
| AR-2    | cross cp_occupancy=empty, cp_r_enb=1                               | read attempted while empty |
| AR-3    | cross cp_occupancy=one, cp_w_enb=1, cp_r_enb=1                     | simultaneous R/W at occupancy 1 |
| AR-4    | cross cp_occupancy=near_full, cp_w_enb=1, cp_r_enb=1                | simultaneous R/W at occupancy Depth-1 |

## 5. Covergroup: cg_pointer_wrap
*Sampled on each accepted write/read, tracked via a testbench event counter. Covers AR-5, AR-6.*

| Plan ID | Coverpoint / Bin                                | Notes |
|---------|-----------------------------------------------------|-------|
| AR-5    | cp_write_wrap: bins wrapped = (total accepted writes crosses a multiple of Depth) | write pointer wraps past end of array |
| AR-6    | cp_read_wrap: same logic, for accepted reads          | read pointer wraps |

## 6. Covergroup: cg_streaks
*Sampled every clock edge, tracking consecutive same-direction operations. Covers AR-7, AR-8.*

| Plan ID | Coverpoint / Bin                                          | Notes |
|---------|----------------------------------------------------------------|-------|
| AR-7    | cp_write_streak: bins reaches_depth (consecutive writes, no reads, count hits Depth) | fills FIFO with no interspersed reads |
| AR-8    | cp_read_streak: same logic, for consecutive reads until empty     | drains FIFO with no interspersed writes |

## 7. Covergroup: cg_reset_recovery
*Sampled around directed reset-mid-transfer tests. Covers AR-9.*

| Plan ID | Coverpoint / Bin                                     | Notes |
|---------|----------------------------------------------------------|-------|
| AR-9    | cp_reset_while_active: bins reset_during_partial_fill      | reset asserted while occupancy is between 1 and Depth-1 |

---

## Summary: what's coverage vs what's correctness

| Category                          | Verified by |
|------------------------------------|-------------|
| Did every scenario in the plan occur? | The covergroups above (this document) |
| Was every response correct?        | Scoreboard (reference model comparison), run continuously |
| Were protected conditions (AR-1, AR-2) actually silent/non-corrupting? | Scoreboard + assertions checking `count`/contents unchanged |