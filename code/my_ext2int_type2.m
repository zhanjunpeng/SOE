function [mat_out] = my_ext2int_type2(idx_ext_int, mat_in)
% change the index in mat_in to mat_out according to the idx_ext and
% idx_int provided in the first and second columns of idx_ext_int
    idx_ext = idx_ext_int(:,1);
    idx_int = idx_ext_int(:,2);
    mat_out = mat_in;
    for i = 1:size(mat_in,1)
        for j = 1:size(mat_in,2)
            idx = find(idx_ext == mat_in(i,j));
            mat_out(i,j) = idx_int(idx);
        end
    end
end