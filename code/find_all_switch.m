function [current_connections, other_possible_connections] = ...
    find_all_switch(Branch0, Branch, from_to, input_node)
% find the current upstream/downstream connection of the input_node: 
% output1: [input_node, upstream_node;
%           input_node, first_downstream_node;]

% find all other possible connections if open the current connection
% output2: each row consists of two nodes [n1 n2], representing close the 
%         branch n1-n2 to replace the current connection

% output 1
upstream_node = find_upstream(from_to, input_node);
current_connections = [input_node, upstream_node]; 
[first_downstream_node, all_downstream_node] = ...
    find_downstream(from_to, input_node);
for i = 1:length(first_downstream_node)
    current_connections = [ current_connections;
        [input_node, first_downstream_node(i)] ];
end

%% output 2
other_possible_connections = [];
% first type: connect/switch the input_node to the not_connected_nodes
not_connected_nodes = ...
    find_all_not_connected_connection(Branch0, Branch, input_node);
for i = 1:length(not_connected_nodes)
    other_possible_connections = [ other_possible_connections; 
        [input_node,  not_connected_nodes(i)] ];
end

% second type: connect/switch one downstream node to its not_connected_nodes
[first_downstream_node, all_downstream_node] = ...
    find_downstream(from_to, input_node);
for i = 1:length(all_downstream_node)
    not_connected_nodes = find_all_not_connected_connection(Branch0, ...
        Branch, all_downstream_node(i));
    for j = 1:length(not_connected_nodes)
        other_possible_connections = [ other_possible_connections; 
            [all_downstream_node(i),  not_connected_nodes(j)] ];
    end
end

end