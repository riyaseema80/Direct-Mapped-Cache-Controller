# Datapath Notes – Direct-Mapped Cache Controller

## 1. Address Decoder

The CPU generates a 32-bit memory address. The address decoder divides this address into three fields:

- **Tag:** 22 bits `[31:10]`
- **Index:** 6 bits `[9:4]`
- **Offset:** 4 bits `[3:0]`

### Purpose of Each Field

1. **Tag:** Identifies which memory block is stored in the selected cache line.
2. **Index:** Selects one of the 64 cache lines.
3. **Offset:** Identifies a byte position within a 16-byte cache block.

The address decoder extracts these fields directly from the CPU address.

### Address Example 1: 0x00000410

32-bit binary representation:

`00000000000000000000010000010000`

| Field | Bit Range | Binary Value | Result |
|---|---|---|---|
| Tag | [31:10] | 0000000000000000000001 | 1 |
| Index | [9:4] | 000001 | 1 |
| Offset | [3:0] | 0000 | 0 |

Therefore:

- Tag = 1
- Index = 1
- Offset = 0

### Address Example 2: 0x000003F0

32-bit binary representation:

`00000000000000000000001111110000`

| Field | Bit Range | Binary Value | Result |
|---|---|---|---|
| Tag | [31:10] | 0000000000000000000000 | 0 |
| Index | [9:4] | 111111 | 63 |
| Offset | [3:0] | 0000 | 0 |

Therefore:

- Tag = 0
- Index = 63
- Offset = 0

### Address Example 3: 0xFFFFFFFF

32-bit binary representation:

`11111111111111111111111111111111`

| Field | Bit Range | Binary Value | Result |
|---|---|---|---|
| Tag | [31:10] | 1111111111111111111111 | 0x3FFFFF |
| Index | [9:4] | 111111 | 63 |
| Offset | [3:0] | 1111 | F |

Therefore:

- Tag = 0x3FFFFF
- Index = 63
- Offset = F

These examples demonstrate how the address decoder separates the CPU address into tag, index and offset fields.

## 2. Tag Comparator

The tag comparator determines whether the requested memory block is already present in the selected cache line.

It compares two values:

- Requested tag: extracted from the CPU address.
- Stored tag: read from the cache tag RAM.

It also checks the valid bit of the selected cache line.

### Hit Logic

The cache hit condition is:

`hit = (requested_tag == stored_tag) && valid_bit`

A cache hit occurs only when:

1. The requested tag matches the stored tag.
2. The valid bit is 1.

### Truth Table

| Requested Tag Matches Stored Tag | Valid Bit | Hit |
|---|---|---|
| Yes | 1 | 1 |
| Yes | 0 | 0 |
| No | 1 | 0 |
| No | 0 | 0 |

### Example

If:

- Requested tag = `22'h155555`
- Stored tag = `22'h155555`
- Valid bit = 1

Then:

`hit = 1`

If the stored tag is `22'h155554` instead, the hit output becomes 0 because the tags do not match.

## 3. Importance of the Valid Bit

The valid bit indicates whether a cache line contains meaningful and initialized data.

In our implementation, all 64 valid bits are initially set to 0.

The tag RAM entries are not explicitly initialized in the current implementation. Therefore, their initial values should not be assumed to be zero.

Without a valid bit, an uninitialized or stale tag could accidentally match a requested tag and produce an incorrect cache hit.

The valid bit prevents this situation.

A cache line is considered valid only when its valid bit is 1.

During a cache refill, the controller updates the cache data, tag and valid bit.

## 4. Synchronous RAM Read Operation

The cache tag RAM, valid RAM and data RAM use synchronous read operations.

Their read outputs are updated on the rising edge of the clock.

For example, the tag RAM uses:

`read_tag <= tag_mem[index];`

Similarly, the valid RAM uses:

`read_valid <= valid_mem[index];`

Because these are clock-triggered operations, changing the index does not immediately update the read output. The output updates at the next rising clock edge.

This introduces a clock-cycle timing requirement in the cache lookup process.

## 5. Relationship Between RAM Read and Controller States

The cache controller uses a Finite State Machine (FSM) to control cache operations.

The relevant lookup sequence is:

### IDLE State

The controller waits for a CPU request.

When `cpu_req` becomes 1, the controller moves to LOOKUP.

### LOOKUP State

The controller moves from LOOKUP to CHECK.

During this state, the synchronous cache RAM outputs are updated on the rising clock edge using the selected index.

The stored tag and valid bit become available for comparison.

### CHECK State

The controller checks the `cache_hit` signal.

Depending on the result:

- If `cache_hit = 1`, it moves to HIT.
- If `cache_hit = 0` and `cpu_write = 0`, it moves to MISS.
- If `cache_hit = 0` and `cpu_write = 1`, it moves to WRITE_WAIT.

The LOOKUP and CHECK sequence allows the RAM outputs to update before the controller makes the hit/miss decision.

## 6. Cache Hit Operation

When the requested block is already present in the cache, the controller enters the HIT state.

For a read hit, the cached data is available to the CPU.

For a write hit:

- Cache data is updated.
- Main memory is also updated.
- The controller then moves to HIT_DONE.

In HIT_DONE, the controller asserts `cpu_ready` to indicate completion.

This implements a write-through policy.

## 7. Cache Read Miss Operation

When a requested block is not present in the cache, the controller follows this sequence:

`MISS → WAIT_MEM → REFILL → RELOAD → COMPLETE`

### MISS

The controller asserts `cache_miss` and `mem_read_en` to request the required block from main memory.

### WAIT_MEM

The controller waits until `mem_ready` becomes 1.

### REFILL

The fetched memory block is written into the cache.

The following information is updated:

- Cache data
- Cache tag
- Cache valid bit

### RELOAD

The controller moves to the RELOAD state after the refill operation.

### COMPLETE

The controller asserts `cpu_ready` to indicate that the operation is complete.

## 8. Cache Write Miss Operation

The current implementation follows a no-write-allocate policy.

When a write miss occurs:

1. The controller enters WRITE_WAIT.
2. `mem_write_en` is asserted.
3. Data is written directly to main memory.
4. The controller moves to WRITE_DONE.
5. `cpu_ready` is asserted.

The missed cache line is not allocated or refilled during this operation.

## 9. Summary

The direct-mapped cache controller uses address decoding, tag comparison, valid-bit checking, synchronous RAM operations and an FSM to manage cache accesses.

The address decoder selects the tag, index and offset fields. The index selects a cache line, while the tag comparator determines whether the requested block matches the stored block.

The valid bit ensures that only initialized cache lines can produce a hit.

The FSM manages cache hits, read misses, cache refill operations and write misses. The implementation uses write-through and no-write-allocate policies.