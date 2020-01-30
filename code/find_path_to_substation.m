function [path_in_node] = find_path_to_substation(from_to, input_node, ...
    substation_node, show_path)
    n = max(from_to(:));
    nodes = [];
    input_node1 = input_node;
    for i = 1:n
        upstream_node = find_upstream(from_to, input_node1);
        if isempty(upstream_node)
            break; % no upstream node
        else
            nodes = [nodes; upstream_node];
        end
        input_node1 = upstream_node;
    end
    
    path_in_node = [input_node, nodes'];
    path_in_node = path_in_node([end:-1:1]);
    if show_path
        fprintf('the path from substation node %d to node %d is: \n', ...
            substation_node, input_node)
        fprintf('%d  ', path_in_node);
        fprintf('\n');
    end
end