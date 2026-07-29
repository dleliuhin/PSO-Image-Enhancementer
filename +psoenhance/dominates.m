function value = dominates(first, second)
%DOMINATES Return true when FIRST Pareto-dominates SECOND.

value = all(first >= second) && any(first > second);
end
