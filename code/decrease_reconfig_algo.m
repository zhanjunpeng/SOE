function [Branch] = decrease_reconfig_algo(Bus, Branch, brch_idx_in_loop, ff0, tt0, ...
    substation_node, n_bus, loss0)
mpopt = mpoption;
mpopt.out.all = 0; % do not print anything
mpopt.verbose = 0;
for iteri = 1:1000
    if ((size(Bus,1)-size(Branch,1)) == 1)
        break;
    end
    loss_i = [];
    for i = 1:length(brch_idx_in_loop)
        Branch_temp = Branch;
        ff = ff0;
        tt = tt0;
        brch_del = brch_idx_in_loop(i);
        ff(brch_del) = [];
        tt(brch_del) = [];
        if n_bus == 417
            nn = n_bus-2;
        elseif n_bus == 119
            nn = n_bus-1;
        else
            nn = n_bus;
        end
        if length(unique([ff;tt])) ~= nn
            loss_i(i) = 1e9;
        else        
            G = graph(ff, tt);
            dd = distances(G, Branch(brch_del, [1 2]), substation_node);
            if all(isfinite(dd)==1) % is connected
                Branch_temp(brch_del,:) = [];    
                mpc = generate_mpc(Bus, Branch_temp, n_bus);
                res = runpf(mpc, mpopt);
                losses = get_losses(res.baseMVA, res.bus, res.branch);
                loss_i(i) = sum(real(losses));
            else % has loop or isolated
                loss_i(i) = 1e9;
            end
        end
        loss_increase_vals(i, [1 2]) = Branch(brch_del, [1 2]);
        loss_increase_vals(i, 3) = loss_i(i) - loss0;
    end
    
    [min_loss, idx_min] = min(loss_i);
    fprintf('line %d-%d is opened, loss increased: %.4f \n', ...
        Branch(brch_idx_in_loop(idx_min), [1 2]), loss_increase_vals(idx_min, 3));
    Branch(brch_idx_in_loop(idx_min), :) = [];
    ff0(brch_idx_in_loop(idx_min)) = [];
    tt0(brch_idx_in_loop(idx_min)) = [];
    brch_idx_in_loop(idx_min) = [];
    brch_idx_in_loop(idx_min:end) = brch_idx_in_loop(idx_min:end)-1;

%     mpc = generate_mpc(Bus, Branch, n_bus);
%     res = runpf(mpc, mpopt);
%     losses = get_losses(res.baseMVA, res.bus, res.branch);
%     loss0 = sum(real(losses)); % updated loss0
end
