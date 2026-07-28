# Algorithm

## Overview

The enhancer searches for four parameters of a local nonlinear transform.
Particle Swarm Optimization is useful here because the objective is
non-differentiable and a small change in a parameter can materially change
the transformed image.

Each particle has:

- a four-element position `[a, b, c, k]`;
- a four-element velocity;
- its historically best position and score.

The swarm also retains the best position observed by any particle.

## Search space

| Parameter | Range | Role |
|---|---:|---|
| `a` | `[0.50, 2.00]` | Nonlinear local-mean response |
| `b` | `[0.01, 0.50]` | Stabilizes gain in low-variance regions |
| `c` | `[0.00, 1.00]` | Controls subtraction of the local mean |
| `k` | `[0.50, 2.00]` | Scales adaptive local gain |

Position and velocity bounds keep the search stable. Inertia decreases
linearly from `0.90` to `0.40`; cognitive and social coefficients are `2.05`.
New independent random values are generated for every particle, dimension,
and iteration.

## Fitness

The objective rewards:

- mean Sobel gradient magnitude;
- the fraction of meaningful edges;
- entropy;
- standard-deviation contrast.

It penalizes the fraction of pixels saturated close to zero or one. All
terms are finite for a constant image, unlike the nested logarithms used by
the original objective.

This remains a no-reference heuristic: a higher score does not guarantee
better subjective quality for every domain. Medical, scientific, or forensic
images require a domain-specific objective and validation.

## Reproducibility

`psoEnhanceImage` resets MATLAB's `twister` generator to `RandomSeed` before
initializing the swarm. The same MATLAB release, image, options, and seed
therefore produce the same result.

## Complexity

For `P` particles, `T` iterations, and an image with `N` pixels, runtime is
approximately `O(P × T × N)`. Increasing the local window mainly changes the
constant factor. Stall detection may stop the search before `T`.
