# Synchronous FIFO — Design Specification

## 1. Overview

A single-clock-domain FIFO (First In, First Out) buffer. Data written in is read out in the same order it was written, with no loss and no duplication, as long as the FIFO is not written to while full or read from while empty.

## 2. Parameters

| Parameter | Default | Description                          |
|-----------|---------|---------------------------------------|
| `Depth`   | 8       | Number of entries the FIFO can hold   |
| `Width`   | 16      | Bit width of each data entry          |

## 3. Interface

| Signal  | Direction | Width       | 
Description                                   |
|---------|-----------|-------------|------------------------------------------------|
| `clk`   | input     | 1           | Clock. All operations are synchronous to its rising edge, except reset. |
| `reset` | input     | 1           | Asynchronous, active-high reset.               |
| `w_enb` | input     | 1           | Write enable. Requests a write on the next rising clock edge. |
| `r_enb` | input     | 1           | Read enable. Requests a read on the next rising clock edge.   |
| `din`   | input     | `Width`     | Data to be written when `w_enb` is asserted.   |
| `dout`  | output    | `Width`     | Data read out when `r_enb` was asserted on the previous cycle. |
| `full`  | output    | 1           | Asserted when the FIFO holds `Depth` entries. No further writes are accepted while asserted. |
| `empty` | output    | 1           | Asserted when the FIFO holds 0 entries. No further reads are accepted while asserted. |

## 4. Functional Behavior

- **Write:** On a rising clock edge, if `w_enb` is asserted and `full` is not asserted, `din` is stored and becomes available for reading in first-in-first-out order.
- **Read:** On a rising clock edge, if `r_enb` is asserted and `empty` is not asserted, the oldest stored entry is presented on `dout` on the following cycle, and that entry is removed from the FIFO.
- **Simultaneous read and write:** A read and a write may be requested on the same clock edge. Both are serviced independently in the same cycle, provided their individual conditions (`!full` for the write, `!empty` for the read) are met.
- **Ordering:** Entries are read out in exactly the order they were written, with no loss, duplication, or reordering, for any valid sequence of writes and reads.

## 5. Protected Conditions (Not Errors)

- **Write while full:** `din` is not stored. `w_enb` being asserted while `full` is asserted has no effect on FIFO state or contents.
- **Read while empty:** `dout` is not updated with new FIFO content `r_enb` being asserted while `empty` is asserted has no effect on FIFO state or contents.

These are defined, protected behaviors — not illegal conditions — and
the FIFO must never corrupt its internal state as a result of either.

## 6. Reset Behavior

Asserting `reset` asynchronously and immediately clears the FIFO to the empty state (`empty` asserted, `full` de-asserted, internal pointers and count cleared), regardless of the state of `clk`, `w_enb`, or `r_enb` at the time. Normal operation resumes on the first rising clock edge after `reset` is de-asserted.

## 7. Out of Scope

- Clock-domain crossing / asynchronous FIFO behavior. This design uses a single clock for both read and write; there is no dual-clock or Gray-code pointer synchronization to verify here.
- Programmable/configurable almost-full or almost-empty threshold flags. This design only exposes full and empty at exactly `Depth` and `0`.