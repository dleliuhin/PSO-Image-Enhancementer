# Changelog

All notable changes are documented here. This project follows
[Semantic Versioning](https://semver.org/).

## [3.1.0] - 2026-07-29

### Added

- Namespaced `+psoenhance` research API.
- Weighted and bounded Pareto multi-objective optimization modes.
- Color-preserving enhancement in CIE Lab luminance.
- Reproducible multi-seed benchmark with four baselines and image-quality
  metrics.
- CC BY 4.0 autonomous-driving sample scenes and generation scripts.
- MATLAB GitHub Actions tests, coverage, benchmark artifacts, and toolbox
  packaging.
- Related-research and benchmark methodology documentation.

### Changed

- Local image statistics are cached once instead of once per particle.
- Optimization can run on a scaled image before applying parameters at full
  resolution.
- A local `RandStream` replaces mutation of MATLAB's global random state.
- RGB input now returns enhanced RGB by default; use
  `ColorMode='grayscale'` for the earlier behavior.

## [3.0.0] - 2026-07-28

### Added

- Reusable `psoEnhanceImage` API with name-value configuration.
- Deterministic optimization through a configurable random seed.
- Velocity clamping, parameter bounds, and stall-based early stopping.
- Optimization diagnostics containing the best parameters and fitness history.
- MATLAB unit tests and expanded English-language project documentation.

### Changed

- Reimplemented the swarm as a four-dimensional optimization over
  `[a, b, c, k]`.
- Replaced the numerically fragile objective with a balanced no-reference
  score and clipping penalty.
- Generalized the local enhancement transform to arbitrary odd window sizes.
- Updated `mainPso` to be a small cross-platform demonstration function.
- Improved validation, naming, documentation, and RGB input handling.

### Fixed

- The final result is now generated from the global-best particle instead of
  the final particle evaluated.
- Personal bests now store parameter vectors rather than unrelated fitness
  scalars.
- Local means now divide by `localSize^2`, not a hard-coded value of nine.
- Flat images no longer cause nested-log singularities in the fitness score.
- Image dimensions are derived from the processed grayscale image.

### Migration notes

- `mainPso` now returns the enhanced image and a result struct when requested.
- `enhanceGsclImage`, `fitnessFunction`, and `getImageSharpness` remain
  available in `sources/`.
- The legacy optional width and height arguments to `fitnessFunction` are
  accepted but ignored.

## [2.1] - 2019-01-26

- Updated PSO parameters.

## [2.0] - 2018-12-16

- Introduced mutated-PSO experiment and generated documentation.

## [1.0] - 2018-12-13

- Initial documented release.

[3.1.0]: https://github.com/dleliuhin/PSO-Image-Enhancement/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/dleliuhin/PSO-Image-Enhancement/compare/2.1...3.0.0
[2.1]: https://github.com/dleliuhin/PSO-Image-Enhancement/releases/tag/2.1
[2.0]: https://github.com/dleliuhin/PSO-Image-Enhancement/releases/tag/2.0
[1.0]: https://github.com/dleliuhin/PSO-Image-Enhancement/releases/tag/1.0
