function [idx_ext_int, Bus, Branch, branch_always_on] = ...
    my_ext2int(Bus, Branch, branch_always_on)
    idx_ext = Bus(:,1);
    idx_int = [1:length(idx_ext)]';
    idx_ext_int = [idx_ext, idx_int];
    Bus(:,1) = idx_int;
    for i = 1:size(Branch,1)
        idx = find(idx_ext == Branch(i,1));
        Branch(i,1) = idx_int(idx);
        idx = find(idx_ext == Branch(i,2));
        Branch(i,2) = idx_int(idx);
    end        
    for i = 1:size(branch_always_on,1)
        idx = find(idx_ext == branch_always_on(i,1));
        branch_always_on(i,1) = idx_int(idx);
        idx = find(idx_ext == branch_always_on(i,2));
        branch_always_on(i,2) = idx_int(idx);
    end
end