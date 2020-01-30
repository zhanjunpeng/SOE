function  [isRadial] = check_radiality_v2(branch12, busid)

isRadial = 0;
[all_connected] = check_connectivity(branch12)
if all_connected
    id1 = branch12(:, [1 2]);
    if length(unique(id1(:))) == length(unique(busid(:)))
        notIsolated = 1;
        if notIsolated
            if size(branch12,1) == (length(busid)-1)
                isRadial = 1;
            end
        end
    else
        notIsolated = 0;
    end
end

end