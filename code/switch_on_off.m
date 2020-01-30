function yij = switch_on_off(Branch0, yij, switch_on, switch_off)
    for i = 1:size(switch_on,1)
        yij_on_idx = find_branch(Branch0, switch_on(i,1), switch_on(i,2));
        yij_off_idx = find_branch(Branch0, switch_off(i,1), switch_off(i,2));
        yij(yij_on_idx) = 1;
        yij(yij_off_idx) = 0;
    end
end