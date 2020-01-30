function [isconnected, duplicate_edge_close, duplicate_edge_open] ...
    = check_radiality(Branch0, Branch, record_mat2, substation_node)
% open_connection2
% close_connection2
% ff0 = Branch0(:,1);  tt0 = Branch0(:,2);
% load record_mat_1122.mat
idx_close = [];  idx_open = [];
duplicate_edge_open = zeros(size(record_mat2,1), 1);
duplicate_edge_close = zeros(size(record_mat2,1), 1);
for ii = 1:size(record_mat2,1)
    open_connection2(1,[1 2]) = record_mat2(ii,[7 8]);
    open_connection2(2,[1 2]) = record_mat2(ii,[9 10]);
    close_connection2(1,[1 2]) = record_mat2(ii,[3 4]);
    close_connection2(2,[1 2]) = record_mat2(ii,[5 6]);
    for i = 1:size(close_connection2,1)
        idx_close(i,1) = find_branch(Branch0, close_connection2(i,1), close_connection2(i,2));
        idx_open(i,1) = find_branch(Branch0, open_connection2(i,1), open_connection2(i,2));
    end
    if length(idx_close)~=length(unique(idx_close))
        duplicate_edge_close(ii,1) = 1;
    end
    if length(idx_open)~=length(unique(idx_open))
        duplicate_edge_open(ii,1) = 1;
    end
end
num_dup_close = length(find(duplicate_edge_close==1))
num_not_dup_close = length(find(duplicate_edge_close==0))
num_dup_open = length(find(duplicate_edge_open==1))
num_not_dup_open = length(find(duplicate_edge_open==0))

for ii = 1:size(record_mat2,1)
    Branch_tmp = Branch;
    if duplicate_edge_close(ii,1) == 1
        isconnected(ii,1) = 0;
    else
        %% perform the swith, i.e., modify the Branch
        idx_to_be_open = [];
        idx_to_be_close = [];
        for i = 1:size(open_connection2, 1)
            idx1 = find_branch(Branch_tmp, ...
                open_connection2(i,1), open_connection2(i,2));
            idx_to_be_open = [idx_to_be_open; idx1];
            idx2 = find_branch(Branch0, ...
                close_connection2(i,1), close_connection2(i,2));
            idx_to_be_close = [idx_to_be_close; idx2];
        end
        Branch_tmp(idx_to_be_open, :) = Branch0(idx_to_be_close, :);

        ff = Branch_tmp(:,1);  tt = Branch_tmp(:,2);
        G = graph(ff, tt);
        dd = distances(G, unique([open_connection2(:); close_connection2(:)]), ...
            substation_node);
        if all(isfinite(dd)==1) % is connected
            isconnected(ii,1) = 1;
        else
            isconnected(ii,1) = 0;
        end
    end
end
end