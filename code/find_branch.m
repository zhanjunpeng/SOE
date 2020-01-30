function [idx] = find_branch(branch, node1, node2)
% find out which row is a branch in a system, given the node# at the 
% two ends of the branch 

% input:
% branch: the first and second columns of branch are the node #, i.e., from
%         and to bus
% node1 and node2: the two ends of a branch

% output:
% idx: the row# of branch(:, [1 2]) such that 
% branch(idx, [1 2])==[node1 node2] OR branch(idx, [1 2])==[node2 node1]

idx1 = find(branch(:,1) == node1);
idx2 = find(branch(:,2) == node2);
idx = [];
for i = 1:length(idx1)
    for j = 1:length(idx2)
        if idx1(i) == idx2(j)
            idx = idx1(i);
        end
    end
end
if isempty(idx)    
    idx1 = find(branch(:,1) == node2); % switch
    idx2 = find(branch(:,2) == node1); % switch
    for i = 1:length(idx1)
        for j = 1:length(idx2)
            if idx1(i) == idx2(j)
                idx = idx1(i);
            end
        end
    end
end
if isempty(idx)
    fprintf('branch %d-%d does not exist in the given system!!!\n', node1, node2)
end

end