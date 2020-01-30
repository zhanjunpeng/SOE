function [ idx ] = getTreeBranchIdx(branch, treeBranch)
% idx(i) = 1 if mpc.branch(i,[1 2]) is in treeBranch
% idx(i) = 0 if mpc.branch(i,[1 2]) is NOT in treeBranch

for i = 1:size(treeBranch, 1)
    treeBranch(i, :) = sort(treeBranch(i, :));
end

% branch = branch(:, [1 2]);
for i = 1:size(branch, 1)
    branch(i, :) = sort(branch(i, :));
end

idx = zeros(size(branch, 1), 1);
for i = 1:size(branch, 1)
    for j = 1:size(treeBranch, 1)
        if branch(i, :) == treeBranch(j, :)
            idx(i) = 1;
            break;
        end
    end
end

end