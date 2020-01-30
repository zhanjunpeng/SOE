function nodes = find_n_steps_from_ending_node(from_to, input_node, n2_up_ending)
% find all the nodes that are within n steps away from ending_node
% length of nodes maybe smaller than n if starting node (i.e., substation
% node is reached
    nodes = [];
    for i = 1:n2_up_ending
        upstream_node = find_upstream(from_to, input_node);
        if isempty(upstream_node)
            fprintf('current node is the starting/substation node, therefore no upstream node\n')
            break; % no upstream node
        else
            nodes = [nodes; upstream_node];
        end
        input_node = upstream_node;
    end
end