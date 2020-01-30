function [branch_idx_focused] = get_branch_idx_focused_for_tabu( ...
    from_to, Branch0, Branch, substation_node, brch_idx_in_loop0, n_bus, ...
    n1_down_substation, n2_up_ending)
%% prepare force open branches: branch_idx_focused
% idx_force_open = [7, 9, 118, 55, 84, 92, 104];
% idx_force_open = [118, 92, 104]; % 104
% idx_force_open = [118]; % 104
% branch_idx_focused = idx_force_open;

ending_node = find_ending_node(Branch, substation_node);
nodes = [];

% n1_down_substation = 4
% n2_up_ending

% n2_up_ending = 2;
% n = 2
for i = 1:length(ending_node)
    nodes = [nodes; find_n_steps_from_ending_node(from_to, ending_node(i), ...
        n2_up_ending)];
end
nodes_2_steps_from_ending_node = unique(nodes);

[first_downstream_node, downstream_node_within_n_steps] = ...
    find_downstream_within_n_steps(from_to, substation_node, n1_down_substation);
nodes_n1_steps_from_substation_node = unique(downstream_node_within_n_steps);

% nodes close to ending nodes and substation node are excluded from force open
% ending nodes and substation node are excluded from force open
all_nodes = [1:n_bus]';
if n_bus == 417
    all_nodes = [1:415]';
elseif n_bus == 119
    all_nodes = [1:118]';
end
nodes_temp = unique([nodes_2_steps_from_ending_node; ...
    nodes_n1_steps_from_substation_node; ending_node; substation_node]);
nodes_medium_steps_from_ending_node = all_nodes;
nodes_medium_steps_from_ending_node(nodes_temp) = [];

% for a branch consists of node i and its upstream node, if this branch is
% not in brch_idx_in_loops, then delete node i from the idx_force_open,
% because if this branch is forced open, the original network departs.
branch_idx_focused = [];    % delete_idx = [];
for i = 1:length(nodes_medium_steps_from_ending_node)
    idx = find(from_to(:, 2) == nodes_medium_steps_from_ending_node(i));
    branch_idx = find_branch(Branch0, from_to(idx,1), from_to(idx,2));

    if find(brch_idx_in_loop0==branch_idx)
        branch_idx_focused = [branch_idx_focused; branch_idx];
    else
%         delete_idx = [delete_idx; i];
% %         delete_node = [delete_node; nodes_medium_steps_from_ending_node(i)];
    end
end
% % nodes_medium_steps_from_ending_node(delete_idx) = [];
% % idx_force_open = nodes_medium_steps_from_ending_node;
