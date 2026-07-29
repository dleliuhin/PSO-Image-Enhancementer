classdef TestPsoEnhanceImage < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPaths(~)
            repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
            addpath(repositoryRoot);
            addpath(fullfile(repositoryRoot, 'sources'));
        end
    end

    methods (Test)
        function outputHasExpectedShapeAndRange(testCase)
            inputImage = uint8(repmat(0:31, 24, 1) * 8);
            [enhanced, result] = psoEnhanceImage(inputImage, ...
                'SwarmSize', 6, 'MaxIterations', 4, ...
                'StallIterations', 4);

            testCase.verifySize(enhanced, size(inputImage));
            testCase.verifyClass(enhanced, 'double');
            testCase.verifyGreaterThanOrEqual(min(enhanced(:)), 0);
            testCase.verifyLessThanOrEqual(max(enhanced(:)), 1);
            testCase.verifySize(result.BestParameters, [1, 4]);
            testCase.verifyNumElements(result.FitnessHistory, ...
                result.Iterations);
        end

        function fixedSeedIsDeterministic(testCase)
            inputImage = uint8(magic(32) ./ max(magic(32), [], 'all') * 255);
            options = {'SwarmSize', 5, 'MaxIterations', 3, ...
                'RandomSeed', 7, 'StallIterations', 3};
            [firstImage, firstResult] = psoEnhanceImage(inputImage, options{:});
            [secondImage, secondResult] = psoEnhanceImage(inputImage, options{:});

            testCase.verifyEqual(firstImage, secondImage);
            testCase.verifyEqual(firstResult.BestParameters, ...
                secondResult.BestParameters);
            testCase.verifyEqual(firstResult.BestFitness, ...
                secondResult.BestFitness);
        end

        function acceptsRgbAndCustomWindow(testCase)
            gray = uint8(repmat(linspace(0, 255, 20), 20, 1));
            rgb = cat(3, gray, fliplr(gray), gray);
            enhanced = psoEnhanceImage(rgb, 'SwarmSize', 4, ...
                'MaxIterations', 2, 'LocalWindowSize', 5, ...
                'StallIterations', 2);

            testCase.verifySize(enhanced, [20, 20, 3]);
            testCase.verifyGreaterThanOrEqual(min(enhanced(:)), 0);
            testCase.verifyLessThanOrEqual(max(enhanced(:)), 1);
        end

        function grayscaleModeRemainsAvailable(testCase)
            rgb = uint8(randi([0, 255], [16, 18, 3]));
            enhanced = psoEnhanceImage(rgb, 'ColorMode', 'grayscale', ...
                'SwarmSize', 4, 'MaxIterations', 2);

            testCase.verifySize(enhanced, [16, 18]);
        end

        function localStreamDoesNotChangeGlobalRng(testCase)
            rng(9182, 'twister');
            stateBefore = rng;
            psoEnhanceImage(uint8(magic(16)), 'SwarmSize', 4, ...
                'MaxIterations', 2, 'RandomSeed', 99);
            stateAfter = rng;

            testCase.verifyEqual(stateAfter, stateBefore);
        end

        function paretoModeReturnsNondominatedArchive(testCase)
            [~, result] = psoEnhanceImage(uint8(magic(20)), ...
                'ObjectiveMode', 'pareto', 'SwarmSize', 8, ...
                'MaxIterations', 4, 'ArchiveSize', 10, ...
                'StallIterations', 4);
            objectives = result.ParetoFront.Objectives;

            testCase.verifyGreaterThan(size(objectives, 1), 0);
            for first = 1:size(objectives, 1)
                for second = 1:size(objectives, 1)
                    if first ~= second
                        testCase.verifyFalse(psoenhance.dominates( ...
                            objectives(first, :), objectives(second, :)));
                    end
                end
            end
        end

        function cachedTransformMatchesCompatibilityFunction(testCase)
            image = mat2gray(magic(24));
            parameters = [1.2, 0.15, 0.4, 1.1];
            statistics = psoenhance.precomputeStatistics(image, 5);
            cached = psoenhance.applyTransform(statistics, parameters);
            compatibility = enhanceGsclImage(image, 5, ...
                parameters(1), parameters(2), parameters(3), parameters(4));

            testCase.verifyEqual(cached, compatibility, 'AbsTol', 1e-12);
        end

        function constantImageHasFiniteFitness(testCase)
            fitness = fitnessFunction(zeros(16));
            testCase.verifyTrue(isfinite(fitness));
            testCase.verifyGreaterThanOrEqual(fitness, 0);
        end

        function rejectsEvenWindow(testCase)
            testCase.verifyError(@() psoEnhanceImage(zeros(8), ...
                'LocalWindowSize', 4), 'MATLAB:InputParser:ArgumentFailedValidation');
        end
    end
end
