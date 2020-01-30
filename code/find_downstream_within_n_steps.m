function [first_downstream_node, downstream_node_within_n_steps] = ...
    find_downstream_within_n_steps(from_to, input_node, n1_down_substation)
% return one or more nodes
% output: first_downstream_node is the downstream nodes derectly connected
%         to the input_node
%         all_downstream_node is all the downstream nodes
idx = find(from_to(:,1) == input_node);
first_downstream_node = from_to(idx,2);

all_downstream_node = [];
current_node = input_node;
cnt = 0;
while ~isempty(current_node)    
    next_current_node = [];
    for i = 1:length(current_node)
        idx = find(from_to(:,1) == current_node(i));
        downstream_node = from_to(idx,2);
        next_current_node = [next_current_node; downstream_node];
        all_downstream_node = [all_downstream_node; downstream_node];
    end
    current_node = next_current_node;
    cnt = cnt+1;
    if cnt == n1_down_substation
        downstream_node_within_n_steps = all_downstream_node;
        break;
    end
end

end