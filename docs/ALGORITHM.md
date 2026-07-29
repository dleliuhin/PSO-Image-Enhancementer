# Algorithm

## Overview

The enhancer searches for four parameters of a local nonlinear transform.
Particle Swarm Optimization is useful because the objective is
non-differentiable and small parameter changes can materially change the
output.

Each particle owns a position `[a, b, c, k]`, velocity, personal-best
position, and objective values. The swarm retains a global compromise and,
in Pareto mode, a bounded archive of nondominated solutions.

For RGB input, optimization operates on CIE Lab luminance. Original chroma
channels are retained, so color is preserved rather than discarded.

## Search space

| Parameter | Range | Role |
|---|---:|---|
| `a` | `[0.50, 1.50]` | Nonlinear local-mean response |
| `b` | `[0.02, 0.50]` | Stabilizes gain in low-variance regions |
| `c` | `[0.00, 1.00]` | Controls subtraction of the local mean |
| `k` | `[0.50, 1.50]` | Scales adaptive local gain |

Position and velocity bounds keep the search stable. Inertia decreases
linearly from `0.90` to `0.40`; cognitive and social coefficients are `2.05`.
Independent random values are generated for every particle, dimension, and
iteration.

Adaptive gain is capped at `4` to limit noise amplification and saturation
in near-constant dark regions.

## Cached local statistics

Local mean and standard-deviation maps do not depend on particle parameters.
Version 3.1 computes them once at full resolution, resizes the cached maps for
the configurable optimization scale, and reuses them for every particle.
Winning parameters are applied once to the full-resolution maps.

## Objective modes

Weighted mode calculates a normalized compromise from four maximization
objectives: detail, information content, contrast, and naturalness. The last
term penalizes clipping and brightness drift exponentially and rewards SSIM
preservation, preventing metric-driven over-enhancement.

Pareto mode keeps a bounded archive of nondominated solutions. Crowding
distance favors leaders in less populated regions of objective space. The API
returns the full archive and selects one weighted compromise for the output;
researchers can select another archive member for their application.

The objective is no-reference and cannot guarantee better subjective quality
for every domain. Medical, scientific, or forensic use requires a
domain-specific objective and validation.

## Reproducibility

The optimizer owns a local `RandStream` initialized from `RandomSeed`; it does
not reset or advance MATLAB's global random stream. The same MATLAB release,
image, options, and seed produce the same result. Benchmarks report
distributions across multiple seeds.

## Complexity

For `P` particles, `T` iterations, an image with `N` pixels, and optimization
scale pixel ratio `s`, runtime is approximately `O(P × T × sN + N)`. Local
statistics cost `O(sN + N)` rather than being recomputed `P × T` times.
