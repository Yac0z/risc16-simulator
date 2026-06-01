# Register File Content Modification Example

## Overview
This example program (`register_modifications.txt`) demonstrates various techniques to modify register file content in the RISC-16 CPU simulator. It shows how different assembly instructions can be used to load, manipulate, and store register values.

## Program Walkthrough

### Initial State
- **ACC (R0)**: 0x0000  
- **PC**: 0x0000  
- **All other registers**: 0x0000

### Instruction-by-Instruction Breakdown

1. **`MTATS 0x10`** (Move To Accumulator This Status)
   - Loads immediate value `0x10` into ACC (R0)
   - **ACC becomes**: 0x0010
   - **Effect**: Register file is modified - R0 now contains 0x0010

2. **`STATS 0x01`** (Store ACC To Status)
   - Stores ACC value (0x0010) into RAM at address 0x01
   - **RAM[0x01] becomes**: 0x0010
   - **Effect**: Data memory modified; ACC remains 0x0010

3. **`LDATS 0x01`** (Load ACC This Status)
   - Loads value from RAM address 0x01 back into ACC
   - **ACC becomes**: 0x0010 (same value, demonstrating round-trip)
   - **Effect**: ACC preserved; shows register persistence through memory

4. **`ADDTS 0x05`** (Add This Status)
   - ACC = ACC + 0x05
   - **ACC becomes**: 0x0010 + 0x05 = 0x0015
   - **Effect**: Arithmetic operation modifies ACC register

5. **`STATS 0x02`** (Store ACC To Status)
   - Stores new ACC value (0x0015) into RAM at address 0x02
   - **RAM[0x02] becomes**: 0x0015
   - **Effect**: Result of arithmetic preserved in memory

6. **`ANDTS 0x0F`** (AND This Status)
   - ACC = ACC AND 0x0F (mask lower 4 bits)
   - **ACC becomes**: 0x0015 AND 0x0F = 0x0005
   - **Effect**: Bitwise AND operation modifies ACC

7. **`ORTS 0x30`** (OR This Status)
   - ACC = ACC OR 0x30 (set bits 4 and 5)
   - **ACC becomes**: 0x0005 OR 0x30 = 0x0035
   - **Effect**: Bitwise OR operation sets bits in ACC

8. **`XORTS 0x3F`** (XOR This Status)
   - ACC = ACC XOR 0x3F (toggle lower 6 bits)
   - **ACC becomes**: 0x0035 XOR 0x3F = 0x000A
   - **Effect**: Bitwise XOR operation toggles bits in ACC

9. **`STATS 0x03`** (Store ACC To Status)
   - Stores final ACC value (0x000A) into RAM at address 0x03
   - **RAM[0x03] becomes**: 0x000A
   - **Effect**: Final result preserved in memory

10. **`JPRT r62`** (Jump To Address in Register 62)
    - Jumps to the address stored in R62 (RPC - Return Program Counter)
    - Creates an infinite loop at current location
    - **Effect**: Program halts execution loop

## Key Registers Modified

| Register | Initial | Final | Operation |
|----------|---------|-------|-----------|
| ACC (R0) | 0x0000  | 0x000A | Multiple arithmetic/logic operations |
| RAM[0x01] | --- | 0x0010 | Stored from ACC after MTATS |
| RAM[0x02] | --- | 0x0015 | Stored after arithmetic (ADD) |
| RAM[0x03] | --- | 0x000A | Stored after bitwise operations |

## Techniques Demonstrated

1. **Immediate Loading**: `MTATS` loads constant values into ACC
2. **Memory Storage**: `STATS` stores register values to RAM
3. **Memory Loading**: `LDATS` loads values from RAM into ACC
4. **Arithmetic Modification**: `ADDTS` adds to register values
5. **Bitwise Operations**: 
   - `ANDTS` masks bits (clearing specific bits)
   - `ORTS` sets bits (enabling specific bits)
   - `XORTS` toggles bits (inverting specific bits)
6. **Register Persistence**: Demonstrates that register values persist until overwritten

## Running the Example

### In the Simulator:
1. Click **"Load .txt/.asm File"** button
2. Select `specs/sample_programs/register_modifications.txt`
3. Click **"Assemble"** to verify syntax
4. Click **"Run"** to execute all instructions, or click **"Next Cycle"** to step through individually

### Observing Results:
- **Left Panel**: Shows current instruction with `▶` marker
- **Right Panel (Register File)**: Watch ACC and other registers change
- **Right Panel (Status Register)**: Flags (Z, N, C, V) may change based on results

## Assembly Instructions Reference

| Instruction | Format | Description | Example |
|------------|--------|-------------|---------|
| MTATS | MTATS immediate | Load immediate into ACC | MTATS 0x10 |
| STATS | STATS address | Store ACC to memory | STATS 0x01 |
| LDATS | LDATS address | Load from memory to ACC | LDATS 0x01 |
| ADDTS | ADDTS immediate | Add immediate to ACC | ADDTS 0x05 |
| ANDTS | ANDTS immediate | AND immediate with ACC | ANDTS 0x0F |
| ORTS | ORTS immediate | OR immediate with ACC | ORTS 0x30 |
| XORTS | XORTS immediate | XOR immediate with ACC | XORTS 0x3F |
| JPRT | JPRT register | Jump to address in register | JPRT r62 |

## ISA Constraints
- **Immediate Range**: 0-63 (6-bit values)
- **Register Count**: 64 registers (R0-R63)
  - R0 = ACC (Accumulator)
  - R62 = RPC (Return Program Counter)
  - R63 = PC (Program Counter)
- **Memory Size**: 65536 addresses (16-bit addressing)
- **Word Width**: 16 bits

## Extending This Example

You can modify this program to:
- Use different immediate values (0-63 range)
- Store/load to different memory addresses
- Chain more arithmetic operations
- Explore different bitwise operations (AND/OR/XOR combinations)
- Use different registers (currently uses ACC, but many instructions support register operands)

## Notes
- The program ends with `JPRT r62`, creating an infinite loop that returns to the current instruction
- All register modifications are tracked in the simulator's register file display
- Memory operations allow data persistence across instruction cycles
