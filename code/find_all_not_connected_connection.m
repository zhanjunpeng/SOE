function not_connected_nodes = find_all_not_connected_connection(Branch0, Branch, input_node)
% find all nodes that are connected to the input_node in Branch0
% but these nodes do not connected to the input_node in Branch
% output: nodes, they may be empty
    all_nodes = find_all_possible_connection(Branch0, input_node);
    connected_nodes = find_all_connected_connection(Branch, input_node);
    idx2 = [];
    for i = 1:length(connected_nodes)
        idx = find(all_nodes==connected_nodes(i));
        if isempty(idx)
        else
            idx2 = [idx2 idx];
        end
    end
    not_connected_nodes = all_nodes;
    not_connected_nodes(idx2) = [];
end