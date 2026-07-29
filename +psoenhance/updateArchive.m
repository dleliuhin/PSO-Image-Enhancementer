function archive = updateArchive(archive, position, objectives, score, limit)
%UPDATEARCHIVE Insert a candidate into a bounded nondominated archive.

if isempty(archive.Objectives)
    keepCandidate = true;
    dominatedExisting = false(0, 1);
else
    dominatedByExisting = false(size(archive.Objectives, 1), 1);
    dominatedExisting = false(size(archive.Objectives, 1), 1);
    for index = 1:size(archive.Objectives, 1)
        dominatedByExisting(index) = psoenhance.dominates( ...
            archive.Objectives(index, :), objectives);
        dominatedExisting(index) = psoenhance.dominates(objectives, ...
            archive.Objectives(index, :));
    end
    duplicate = any(all(abs(bsxfun(@minus, archive.Objectives, objectives)) ...
        < 1e-12, 2));
    keepCandidate = ~any(dominatedByExisting) && ~duplicate;
end

archive.Positions(dominatedExisting, :) = [];
archive.Objectives(dominatedExisting, :) = [];
archive.Scores(dominatedExisting, :) = [];
if keepCandidate
    archive.Positions(end + 1, :) = position;
    archive.Objectives(end + 1, :) = objectives;
    archive.Scores(end + 1, 1) = score;
end

archive.CrowdingDistance = crowdingDistance(archive.Objectives);
while size(archive.Positions, 1) > limit
    finiteDistances = archive.CrowdingDistance;
    finiteDistances(isinf(finiteDistances)) = realmax;
    [~, removeIndex] = min(finiteDistances);
    archive.Positions(removeIndex, :) = [];
    archive.Objectives(removeIndex, :) = [];
    archive.Scores(removeIndex, :) = [];
    archive.CrowdingDistance = crowdingDistance(archive.Objectives);
end
end

function distance = crowdingDistance(objectives)
count = size(objectives, 1);
distance = zeros(count, 1);
if count <= 2
    distance(:) = inf;
    return;
end
for dimension = 1:size(objectives, 2)
    [ordered, order] = sort(objectives(:, dimension));
    distance(order([1, end])) = inf;
    range = ordered(end) - ordered(1);
    if range > 0
        for index = 2:(count - 1)
            distance(order(index)) = distance(order(index)) ...
                + (ordered(index + 1) - ordered(index - 1)) / range;
        end
    end
end
end
