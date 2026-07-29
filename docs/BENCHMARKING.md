# Benchmarking

## Purpose

`psoenhance.benchmark` provides a repeatable comparison rather than treating
a visually pleasing example as evidence. It compares:

- the unmodified input;
- linear intensity adjustment (`imadjust`);
- gamma correction (`gamma = 0.5`);
- histogram equalization (`histeq`);
- CLAHE (`adapthisteq`);
- weighted-objective PSO;
- Pareto PSO.

## Reproduce the repository benchmark

```matlab
[runs, summary] = runBenchmark( ...
    'Seeds', 1:10, ...
    'SwarmSize', 24, ...
    'MaxIterations', 50);
```

`benchmark-runs.csv` contains one row per method, image, and seed.
`benchmark-summary.csv` reports mean and standard deviation. PSO methods run
once for every requested seed; deterministic baselines run once.

## Metrics

| Metric | Direction | Interpretation |
|---|:---:|---|
| Entropy | ↑ | intensity-distribution information |
| Contrast | ↑ | standard deviation of luminance |
| Average gradient | ↑ | local edge/detail strength |
| Edge density | contextual | fraction of meaningful Sobel responses |
| Clipping fraction | ↓ | pixels saturated near 0 or 1 |
| Brightness shift | ↓ | mean-luminance change from a reference |
| PSNR / SSIM | ↑ | fidelity when a clean reference exists |
| NIQE / BRISQUE / PIQE | ↓ | optional no-reference perceptual scores |
| Runtime | ↓ | elapsed wall-clock time |

No single metric establishes perceptual superiority. Entropy and gradient can
increase when noise is amplified; PSNR can penalize a useful contrast change.
Report the full metric vector, images, runtime, and seed distribution.

## Dataset

The committed examples use two front-camera frames from the CC BY 4.0
CARLA–nuScenes dataset. One is a simulated night scene; the other is
deterministically degraded to provide a known reference. Provenance and
license details are in
[`examples/autonomous-driving/ATTRIBUTION.md`](../examples/autonomous-driving/ATTRIBUTION.md).

This two-image benchmark is a reproducible smoke benchmark, not a claim of
state-of-the-art generalization. Publications should additionally evaluate
larger domain-specific datasets and report confidence intervals.
