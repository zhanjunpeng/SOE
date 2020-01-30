function [upstream_node] = find_upstream(from_to, input_node)    
% return one and only one upstream node of the input_node
    idx = find(from_to(:,2)==input_node);
    if isempty(idx)
        fprintf('there is no upstream node of input_node %d\n', input_node)
        upstream_node = [];
    end
    upstream_node = from_to(idx,1);
end