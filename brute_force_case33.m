clear all, clc, close all
ver_num_reconfig_dec = 0
%% basic setting
tic
fprintf('decrease_reconfig_33_tabu.m \n')
warning('off')
addpath(pathdef)
mpopt = mpoption;
mpopt.out.all = 0; % do not print anything
mpopt.verbose = 0;
version_LODF = 0 % 1: use decrease_reconfig_algo_LODF.m
                 % 0: use decrease_reconfig_algo.m

candi_brch_bus = []; % candidate branch i added to bus j
% mpc0 = case33;
casei=4
d33zhu_v2
nbus = 33;
substation_node = 1;        n_bus = 33;

n1 = 3
n2 = 5
n1_down_substation = n1+1;    n2_up_ending = n2;

Branch0 = Branch;
brch_idx_in_loop0 = unique(brch_idx_in_loop(:));

%% original network's power flow (not radial)
% show_biograph(Branch, Bus)
from_to = show_biograph_not_sorted(Branch, substation_node, 0); 
mpc = generate_mpc(Bus, Branch, n_bus);
res_orig = runpf(mpc, mpopt);
losses = get_losses(res_orig.baseMVA, res_orig.bus, res_orig.branch);
loss0 = sum(real(losses));
fprintf('case33_tabu: original loop network''s loss is %.5f \n\n', loss0)
mpc0 = mpc;
nbr = size(Branch,1);
mpc_save = [];
cnt = 0;
for i1 = 1:nbr
    fprintf('i1=%d\n', i1);
    for i2 = 1:nbr
        if i2>i1
        for i3 = 1:nbr
            if i3>i2
            for i4 = 1:nbr
                if i4>i3
                for i5 = 1:nbr
                    if i5>i4
                    idx = [i1, i2, i3, i4, i5];
                    if length(unique(idx)==5)
                        Branch = Branch0;
                        mpc = mpc0;
                        Branch(idx, :) = [];
                        mpc.branch(idx, :) = [];
                        all_connected = check_connectivity(Branch);
                        if all_connected
                            cnt = cnt+1;
                            mpc_save{cnt} = mpc;
                        end
                    end
                    end
                end
                end
            end
            end
        end
        end
    end
end
save('mpc_save.mat', 'mpc_save')

load mpc_save.mat
n = length(mpc_save);
loss_save = 9999*ones(n,1);
j = 0;
cnt_loop = 0; cnt_radial = 0;
for i = 1:n
    if rem(i,5000)==0
        fprintf('i=%d/%d\n', i,n)
    end
    mpc = [];
    mpc = mpc_save{i};
    if length(unique(mpc.branch(:,[1 2]))) == nbus  
        cnt_radial = cnt_radial+1;
    else
        cnt_loop = cnt_loop+1;
    end
end
cnt_radial
cnt_loop

for i = 1:n
    if rem(i,5000)==0
        fprintf('i=%d/%d\n', i,n)
    end
    mpc = [];
    mpc = mpc_save{i};
    if length(unique(mpc.branch(:,[1 2]))) == nbus    
        [Vbus, IB, loss_sweep_MW] = SweepPowerFlow_v2(mpc, 1000);
        loss_save(i) = loss_sweep_MW;        
    else
        j = j+1;
        res_pf_dec_save{j}.i = i;        
        res_pf_dec_save{j}.mpc = mpc; 
    end
%     res_pf_dec = runpf(mpc, mpopt);
%     if res_pf_dec.success
%         losses = get_losses(res_pf_dec.baseMVA, res_pf_dec.bus, res_pf_dec.branch);
%         loss0_dec = sum(real(losses));  % 
%         loss_save(i) = loss0_dec;
%     else
%         j = j+1;
%         res_pf_dec_save{j} = res_pf_dec;
%         res_pf_dec_save{j}.i = i;        
%         res_pf_dec_save{j}.mpc = mpc; 
%     end
end
[min_value, min_idx] = min(loss_save)
mpc_save{min_idx}
save('res_pf_dec_save.mat', 'loss_save', 'res_pf_dec_save')

%%
load mpc_save.mat
mpc34228 = mpc_save{34228};
G = graph(mpc34228.branch(:,1), mpc34228.branch(:,2));
plot(G)

%% 
fprintf('\n')
ver_num_reconfig_dec