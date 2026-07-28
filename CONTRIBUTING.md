# Contributing

Thank you for helping improve PSO Image Enhancement.

## Development workflow

1. Fork the repository and create a focused branch.
2. Keep MATLAB code compatible with MATLAB R2018b and the Image Processing
   Toolbox.
3. Add or update tests for behavioral changes.
4. Run `results = runtests("tests"); assertSuccess(results);`.
5. Update `README.md` or `CHANGELOG.md` when the public behavior changes.
6. Open a pull request describing the motivation, implementation, and test
   results.

## MATLAB style

- Prefer descriptive camelCase names and one public function per file.
- Validate public inputs and return useful diagnostics.
- Vectorize only when it remains readable.
- Use `fullfile` for paths and avoid workspace-clearing side effects.
- Document randomness and provide a seed for reproducible examples.

## Issues

For bugs, include the MATLAB release, operating system, toolbox version,
minimal reproduction, expected result, actual result, and a small non-private
test image where possible.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
