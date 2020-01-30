function [nodes] = find_all_possible_connection(Branch0, input_node)
% find all possible connection from the original Branch data, i.e., Branch0
% of input_node, 
% output: nodes that have connection to input_node
    idx1 = find(Branch0(:,1) == input_node);
    nodes1 = Branch0(idx1, 2);
    idx2 = find(Branch0(:,2) == input_node);
    nodes2 = Branch0(idx2, 1);
    nodes = [nodes1(:); nodes2(:)];
end