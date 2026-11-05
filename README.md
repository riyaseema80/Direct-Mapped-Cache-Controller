# Direct-Mapped Cache Controller

A Verilog HDL-based implementation of a Direct-Mapped Cache Controller for the Modern Computer Architecture course.

## Project Overview

This project aims to design and implement a direct-mapped cache memory system that improves memory access efficiency by storing frequently accessed data closer to the processor.

The controller handles cache lookup, hit/miss detection, memory access and cache block replacement.

## Objectives

- Understand direct-mapped cache architecture.
- Implement Tag, Index and Offset address fields.
- Design cache storage using Verilog HDL.
- Implement cache hit and miss detection.
- Design cache refill and memory interface logic.
- Analyze cache performance using hit rate, miss rate and AMAT.

## Proposed Cache Configuration

| Parameter | Value |
|---|---|
| Address Width | 32 bits |
| Cache Size | 1 KB |
| Block Size | 16 bytes |
| Number of Cache Lines | 64 |
| Mapping | Direct Mapped |

## Address Breakdown

- Tag: 22 bits
- Index: 6 bits
- Block Offset: 4 bits

## Project Structure

- `rtl/` – Verilog source modules
- `testbench/` – Verification testbenches
- `simulation/` – Simulation outputs and waveforms
- `documentation/` – Architecture and design documentation
- `report/` – Final project report

## Tools and Technologies

- Verilog HDL
- Icarus Verilog / ModelSim
- GTKWave
- Git and GitHub
- Vivado (if FPGA synthesis is available)

## Performance Metrics

- Cache Hit Rate
- Cache Miss Rate
- Average Memory Access Time (AMAT)

## Team

Five-member team project.

## Project Status

Initial repository setup completed. RTL implementation and verification are planned next.

## Course

Modern Computer Architecture – B.Tech (CS&AI)
