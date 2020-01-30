function [loss_after_switch, Branch_out] = find_loss_change(Bus, ...
    Branch0, Branch, open_connection, close_connection, substation_node, ...
    n_bus)
% function [loss_after_switch, loss_before_switch, Branch_out] = find_loss_change(Bus, ...
%     Branch0, Branch, open_connection, close_connection, substation_node, ...
%     n_bus)
    mpopt = mpoption;
    mpopt.out.all = 0; % do not print anything
    mpopt.verbose = 0;
    
% %% obtain the loss before switch
%     mpc = generate_mpc(Bus, Branch, n_bus);
%     res_pf = runpf(mpc, mpopt);
%     losses = get_losses(res_pf.baseMVA, res_pf.bus, res_pf.branch);
%     loss_before_switch = sum(real(losses));  % cannot be deleted, need to be used for comparison
    
%% perform the swith, i.e., modify the Branch
    idx_to_be_open = [];
    idx_to_be_close = [];
    for i = 1:size(open_connection, 1)
        idx1 = find_branch(Branch, ...
            open_connection(i,1), open_connection(i,2));
        idx_to_be_open = [idx_to_be_open; idx1];
        idx2 = find_branch(Branch0, ...
            close_connection(i,1), close_connection(i,2));
        idx_to_be_close = [idx_to_be_close; idx2];
    end
    Branch(idx_to_be_open, :) = Branch0(idx_to_be_close, :);
    
%     for i = 1:size(open_connection, 1)
%         fprintf('open %d-%d, ', Branch(idx_to_be_open(i), [1 2]));
%         fprintf('close %d-%d \n', Branch0(idx_to_be_close(i), [1 2]));
%     end
    
%% obtain the loss after swith
    mpc = generate_mpc(Bus, Branch, n_bus);
    res_pf = runpf(mpc, mpopt);
    losses = get_losses(res_pf.baseMVA, res_pf.bus, res_pf.branch);
    loss_after_switch = sum(real(losses));
%     if res_pf.success==0
%         [Vbus, IB, loss_sweep_MW] = SweepPowerFlow_v2(mpc, 1000);
%         loss_after_switch = loss_sweep_MW*1000;
%     end
    
    Branch_out = Branch;
end