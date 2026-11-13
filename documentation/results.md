
# Direct-Mapped Cache Controller — Simulation Results

## 1. Overview

The Direct-Mapped Cache Controller was tested using
four different memory access patterns to evaluate
cache performance and verify hit/miss behaviour.

The simulation uses:
- Cache Hit Latency: 4 cycles
- Cache Miss Latency: 7 cycles
- Miss Penalty: 3 cycles

## 2. Trace-wise Performance Results

| Trace | Reads | Read Hits | Hit Rate | AMAT |
|---|---:|---:|---:|---:|
| Trace 1: Sequential | 16 | 12 | 75% | 4.75 cycles |
| Trace 2: Conflict | 6 | 0 | 0% | 7.00 cycles |
| Trace 3: Random (2 KB) | 15 | 0 | 0% | 7.00 cycles |
| Trace 4: Random (1 KB) | 50 | 25 | 50% | 5.50 cycles |

## 3. Trace Analysis

### Trace 1: Sequential Access
- Total reads: 16
- Read hits: 12
- Read misses: 4
- Hit rate: 75%

Sequential access achieves a high hit rate because
consecutive addresses benefit from spatial locality.
After loading a cache block, subsequent accesses
within that block can be served as cache hits.

### Trace 2: Conflict Access
- Total reads: 6
- Read hits: 0
- Read misses: 6
- Hit rate: 0%

The two alternating addresses (0x30 and 0x430)
map to the same cache index but have different tags.
They continuously replace each other, resulting in
conflict misses on every access.

### Trace 3: Random Access (2 KB)
- Total reads: 15
- Read hits: 0
- Read misses: 15
- Hit rate: 0%

The only hit in this trace was a write hit, which is not counted in the read hit rate.
Random accesses across a larger address range have
low temporal locality. Most accesses result in misses
because previously loaded cache blocks are not reused.

### Trace 4: Random Access (1 KB)
- Total reads: 50
- Read hits: 25
- Read misses: 25
- Hit rate: 50%

Restricting random accesses to a 1 KB address range
increases the opportunity to reuse previously accessed
cache blocks. Repeated accesses to cached blocks
result in cache hits.

## 4. AMAT Calculation

Formula:

AMAT = Hit Time + (Miss Rate × Miss Penalty)

AMAT = 4 + (1 - Hit Rate) × 3

Where:
- Hit Time = 4 cycles
- Miss Penalty = 3 cycles

### Calculated AMAT

- Trace 1: 4 + (1 - 0.75) × 3 = 4.75 cycles
- Trace 2: 4 + (1 - 0.00) × 3 = 7.00 cycles
- Trace 3: 4 + (1 - 0.00) × 3 = 7.00 cycles
- Trace 4: 4 + (1 - 0.50) × 3 = 5.50 cycles

## 5. Overall Simulation Summary

According to the simulation output:

- Total cache hits: 42
- Total cache misses: 59
- Total read hits: 40
- Total read misses: 54
- Overall read hit rate: 42.55%
- Overall read miss rate: 57.45%
- Overall AMAT: 5.723404 cycles
- Checks passed: 103
- Checks failed: 0

## 6. Verification

The testbench successfully verified the cache
controller using its reference model.

All 103 checks passed with zero failures.

The simulation confirmed correct cache hit/miss
behaviour across sequential, conflict and random
access patterns.

## 7. Conclusion

The simulation demonstrates how memory access
patterns affect direct-mapped cache performance.

Sequential access achieved the highest hit rate
of 75%, while conflict access resulted in 0% hits.
The new 1 KB random trace achieved a 50% hit rate,
showing the benefit of restricting the address range
and increasing opportunities for cache reuse.
