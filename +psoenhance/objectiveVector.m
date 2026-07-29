function objectives = objectiveVector(metrics)
%OBJECTIVEVECTOR Map raw metrics to four bounded maximization objectives.

detail = tanh(8 * metrics.AverageGradient) ...
    * (0.5 + 0.5 * min(1, 2 * metrics.EdgeDensity));
information = min(1, metrics.Entropy / 8);
contrast = min(1, metrics.Contrast / 0.30);
if isfinite(metrics.BrightnessShift)
    brightnessPreservation = max(0, 1 - metrics.BrightnessShift / 0.35);
else
    brightnessPreservation = 1;
end
naturalness = max(0, 1 - metrics.ClippingFraction) ...
    * (0.5 + 0.5 * brightnessPreservation);

objectives = [detail, information, contrast, naturalness];
end
