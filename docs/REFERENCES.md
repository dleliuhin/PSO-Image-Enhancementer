# Related research

These papers are the closest methodological references for this repository.
Links use persistent DOI resolvers.

1. J. Kennedy and R. Eberhart, “Particle Swarm Optimization,” *Proceedings
   of ICNN'95*, pp. 1942–1948, 1995.
   [doi:10.1109/ICNN.1995.488968](https://doi.org/10.1109/ICNN.1995.488968)

2. A. Gorai and A. Ghosh, “Gray-level Image Enhancement by Particle Swarm
   Optimization,” *World Congress on Nature & Biologically Inspired
   Computing*, 2009.
   [doi:10.1109/NABIC.2009.5393603](https://doi.org/10.1109/NABIC.2009.5393603)

3. Z. Ye, H. Mohamadian, and Y. Ye, “An Adaptive Image Enhancement Technique
   by Combining Cuckoo Search and Particle Swarm Optimization Algorithm,”
   *Computational Intelligence and Neuroscience*, 2015.
   [doi:10.1155/2015/825398](https://doi.org/10.1155/2015/825398)

4. M. Wan et al., “Particle Swarm Optimization-based Local Entropy Weighted
   Histogram Equalization for Infrared Image Enhancement,” *Infrared Physics
   & Technology*, vol. 91, pp. 164–181, 2018.
   [doi:10.1016/j.infrared.2018.04.003](https://doi.org/10.1016/j.infrared.2018.04.003)

5. X. Zhang et al., “A Color Image Contrast Enhancement Method Based on
   Improved PSO,” *PLOS ONE*, vol. 18, 2023.
   [doi:10.1371/journal.pone.0274054](https://doi.org/10.1371/journal.pone.0274054)

## Relationship to the implementation

The four-parameter local/global transform and the original edge-and-entropy
criterion trace directly to Gorai and Ghosh. Version 3.1 retains that
interpretable transform but adds bounded objectives, clipping protection,
true color-luminance processing, cached local statistics, deterministic
multi-seed experiments, and a bounded Pareto archive.

Pareto mode is an engineering research extension, not a reproduction of any
single paper above. Describe results as inspired by the cited work, not as an
official implementation of the authors' methods.
