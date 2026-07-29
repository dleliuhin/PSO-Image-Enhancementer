classdef TestMetricsAndArchive < matlab.unittest.TestCase
    methods (Test)
        function metricsAreFiniteForConstantImage(testCase)
            metrics = psoenhance.computeMetrics(zeros(16));
            objectives = psoenhance.objectiveVector(metrics);

            testCase.verifyTrue(all(isfinite(objectives)));
            testCase.verifyGreaterThanOrEqual(objectives, zeros(1, 4));
            testCase.verifyLessThanOrEqual(objectives, ones(1, 4));
        end

        function archiveRemovesDominatedPoints(testCase)
            archive = struct('Positions', zeros(0, 4), ...
                'Objectives', zeros(0, 4), 'Scores', zeros(0, 1), ...
                'CrowdingDistance', zeros(0, 1));
            archive = psoenhance.updateArchive(archive, ones(1, 4), ...
                [0.2, 0.2, 0.2, 0.2], 0.2, 5);
            archive = psoenhance.updateArchive(archive, 2 .* ones(1, 4), ...
                [0.8, 0.8, 0.8, 0.8], 0.8, 5);

            testCase.verifySize(archive.Positions, [1, 4]);
            testCase.verifyEqual(archive.Objectives, ...
                [0.8, 0.8, 0.8, 0.8]);
        end

        function statisticsAreComputedOnceAndReusable(testCase)
            image = mat2gray(peaks(32));
            statistics = psoenhance.precomputeStatistics(image, 3);
            first = psoenhance.applyTransform(statistics, ...
                [1.0, 0.1, 0.5, 1.0]);
            second = psoenhance.applyTransform(statistics, ...
                [1.4, 0.2, 0.3, 1.2]);

            testCase.verifySize(first, size(image));
            testCase.verifySize(second, size(image));
            testCase.verifyNotEqual(first, second);
        end

        function cachedStatisticsCanBeScaled(testCase)
            statistics = psoenhance.precomputeStatistics(zeros(40, 60), 3);
            scaled = psoenhance.scaleStatistics(statistics, 0.5);

            testCase.verifySize(scaled.Image, [20, 30]);
            testCase.verifySize(scaled.LocalMean, [20, 30]);
            testCase.verifySize(scaled.LocalStd, [20, 30]);
            testCase.verifyEqual(scaled.GlobalMean, statistics.GlobalMean);
        end
    end
end
