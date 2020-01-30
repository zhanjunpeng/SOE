function [nodes_focused] = get_nodes_focused_o1c1( ...
    from_to, Branch, Branch0, substation_node, brch_idx_in_loop, ...
    n1_down_substation, n2_up_ending)
% prepare nodes_focused for one_open_one_close    

    % all the nodes within n2_up_ending steps away from ending_nodes
    ending_node = find_ending_node(Branch, substation_node);
    nodes = [];
%     n2_up_ending = 2;
    for i = 1:length(ending_node)
        nodes = [nodes; find_n_steps_from_ending_node(from_to, ...
            ending_node(i), n2_up_ending)];
    end
    nodes_focused = unique([nodes; ending_node]);
    
    % exclude/delete substation node
    idx = find(nodes_focused==substation_node);
    nodes_focused(idx) = [];
    
    % exclude/delete nodes within 3 steps to the substation node
    [first_downstream_node, downstream_node_within_n_steps] = ...
        find_downstream_within_n_steps(from_to, substation_node, ...
        n1_down_substation);
    nodes_n1_steps_from_substation_node = unique(downstream_node_within_n_steps);
    nodes_delete = unique([nodes_n1_steps_from_substation_node]);
    delete_idx = [];
    idx = [];
    for i = 1:length(nodes_delete)
        idx = find(nodes_focused==nodes_delete(i));
        delete_idx = [delete_idx; idx];
    end
    
    % for a branch consists of node i and its upstream node, if this branch is
    % not in brch_idx_in_loop, then exclude/delete node i from the nodes_focused,
    % because if this branch is forced open, the original network departs.    
    for i = 1:length(nodes_focused)
        idx = find(from_to(:, 2) == nodes_focused(i));
        branch_idx = find_branch(Branch0, from_to(idx,1), from_to(idx,2));

        if find(brch_idx_in_loop==branch_idx)
        else
            delete_idx = [delete_idx; i];
    %         delete_node = [delete_node; nodes_medium_steps_from_ending_node(i)];
        end
    end
    nodes_focused(delete_idx) = [];
    nodes_focused = unique(nodes_focused);
end