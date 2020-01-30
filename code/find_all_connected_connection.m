function [nodes] = find_all_connected_connection(Branch, input_node)
% find all nodes already connected to the input_node in the Branch
    idx1 = find(Branch(:,1) == input_node);
    nodes1 = Branch(idx1,2);
    idx2 = find(Branch(:,2) == input_node);
    nodes2 = Branch(idx2,1);
    nodes = [nodes1(:); nodes2(:)];
end