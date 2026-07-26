# Synchronous FIFO — Verification Plan

Derived from docs/design_spec.md. Methodology: features identified via interface-based, function-based, and architecture-based analysis.


---

## 1. Interface-Based Features

*What transactions and signal combinations can occur at the pins.*

| ID    | Feature                                                              | Spec Ref |
|-------|-----------------------------------------------------------------------|----------|
| IF-1  | `w_enb` asserted alone (no read) must write `din` on that edge.       | §4       |
| IF-2  | `r_enb` asserted alone (no write) must read the oldest entry.         | §4       |
| IF-3  | Neither `w_enb` nor `r_enb` asserted — FIFO state must not change.    | §4       |
| IF-4  | Both `w_enb` and `r_enb` asserted on the same edge (simultaneous R/W).| §4       |
| IF-5  | `din` must be driven across its full data range (`Width`-bit values, including all-0s and all-1s).| §3 |
| IF-6  | `reset` asserted while `clk` is mid-cycle (asynchronous assertion, not aligned to an edge). | §6 |
| IF-7  | `reset` asserted while `w_enb`/`r_enb` are also asserted.             | §6       |

## 2. Function-Based Features

*What the design is supposed to guarantee, per the spec's stated behavior.*

| ID    | Feature                                                                 | Spec Ref |
|-------|----------------------------------------------------------------------------|----------|
| FN-1  | Data is read out in exactly the order it was written (FIFO ordering), for any legal sequence of writes/reads. | §4 |
| FN-2  | No data loss: every accepted write is eventually readable exactly once. | §4       |
| FN-3  | No data duplication: no entry is presented on `dout` more than once.   | §4       |
| FN-4  | `full` is asserted if and only if the FIFO holds exactly `Depth` entries. | §3, §4 |
| FN-5  | `empty` is asserted if and only if the FIFO holds exactly 0 entries.   | §3, §4   |
| FN-6  | After reset, FIFO reports `empty` and not `full`, regardless of pre-reset state. | §6 |

## 3. Architecture-Based Features

*Conditions that stress this specific implementation toward its limits.*

| ID    | Feature                                                                    | Spec Ref |
|-------|-----------------------------------------------------------------------------|----------|
| AR-1  | Writing while `full` must not corrupt FIFO contents or change `count`/pointers. | §5   |
| AR-2  | Reading while `empty` must not corrupt FIFO contents or change `count`/pointers. | §5   |
| AR-3  | Simultaneous read+write while FIFO holds exactly 1 entry (transition toward empty, from the read side, while a write also lands). | §4 |
| AR-4  | Simultaneous read+write while FIFO holds exactly `Depth`-1 entries (transition toward full, from the write side, while a read also lands). | §4 |
| AR-5  | Write pointer wraparound: fill, drain, and refill past the physical end of the memory array (pointer wraps from `Depth-1` back to `0`). | (impl. detail — pointer-based storage implied by §4 ordering guarantee) |
| AR-6  | Read pointer wraparound — same as AR-5, from the read side.               | (impl. detail) |
| AR-7  | Back-to-back writes until full, with no reads interspersed.                | §3, §4   |
| AR-8  | Back-to-back reads until empty, with no writes interspersed.               | §3, §4   |
| AR-9  | `reset` asserted mid-transfer (FIFO partially full, a write and/or read in flight) — must return cleanly to the empty state. | §6 |

---

## 4. Test Approach

- **Directed tests** for AR-1 through AR-9 and IF-6/IF-7 — these are
  specific, known corner cases where you want a test that *deliberately*
  drives the design into that exact condition, not one that hopes random
  stimulus stumbles into it.
- **Constrained-random stimulus** for general FN-1/FN-2/FN-3 confidence —
  long random sequences of writes/reads/simultaneous-R/W, checked against
  a reference model, to catch anything the directed tests didn't
  anticipate.
- **Reference model:** a simple queue (SystemVerilog `$` queue or array)
  in the testbench that mirrors expected FIFO contents, used to check
  `dout` against on every read.

## 5. Out of Scope

- Timing/setup-hold violations on the interface (this is a functional
  verification plan, not a timing verification plan).
- CDC — not applicable, per design_spec.md §7.