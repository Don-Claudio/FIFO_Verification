# Synchronous FIFO — Verification Project

A single-clock synchronous FIFO, verified against a written spec and
verification plan. Built as a portfolio project to practice
industry-style verification methodology (spec → plan → coverage model →
testbench).

## Status

- [x] Design specification
- [x] Verification plan
- [ ] Functional coverage (covergroups matching coverage_model.md)
- [x] Testbench (driver / monitor / scoreboard / coverage)
- [x] First clean simulation run (0 mismatches, 200 transactions)
- [ ] Lint / CI

## Structure

- `docs/` — specification, verification plan, coverage model
- `rtl/` — the DUT (sourced from kranthiuppada/synchronous-fifo, MIT)
- `tb/` — testbench
- `sim/` — Questa run scripts
- `scripts/` — lint / utility scripts

## Running

*(to be filled in once `sim/` exists)*
