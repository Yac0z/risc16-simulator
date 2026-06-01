# Architecture Decisions

## ADR-001 - 16-bit RISC ISA with 64-register file
Status: Accepted
Date: 2026-04-10

Context:
The assignment defines a one-address 16-bit RISC CPU with 64 registers, including dedicated ACC/PC/RPC registers.

Decision:
Implement a register file with 64x16 storage and explicit control enables for ACC (R0), RPC (R62), and PC (R63).

Consequences:
- Datapath stays simple and aligned with educational goals.
- Control logic must route special-write paths explicitly.

## ADR-002 - Five-stage FSM micro-cycle
Status: Accepted
Date: 2026-04-10

Context:
The ISA requires each instruction to execute in five cycles: fetch1, fetch2, decode, exec, store.

Decision:
Model control as a cyclic FSM with deterministic state transition every cycle.

Consequences:
- Timing behavior is predictable and testable.
- Throughput is lower than pipelined design but matches assignment.

## ADR-003 - numeric_std only
Status: Accepted
Date: 2026-04-10

Context:
Arithmetic correctness and synthesizer portability require standard VHDL numeric semantics.

Decision:
Use IEEE.numeric_std with explicit signed/unsigned casts.

Consequences:
- Better portability between tools.
- Slightly more verbose conversions.

## ADR-004 - ISA encoding values are guarded until table verification
Status: Proposed
Date: 2026-04-10

Context:
The PDF extraction missed full text of opcode/condition tables due image-rendered segments.

Decision:
Bootstrap with ISA package placeholders and explicit verification comments. Treat final opcode mapping as a gating review item.

Consequences:
- Development can start on structure and unit behavior.
- Final integration blocked until exact table values are confirmed.
