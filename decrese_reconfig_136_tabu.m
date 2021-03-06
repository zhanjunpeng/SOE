clear all, clc, close all
addpath('./code')
ver_num_reconfig_dec = 4

get_brch_tabu_v2 = 0
debug_flag = 0
gen_type = 0
season = 'summer' % 'summer', 'winter'
% hours  = 'night' % 'day', 'night', '24'
season, gen_type

%% basic setting
tic
fprintf('decrese_reconfig_136_tabu_renew.m (1 hour) \n')
warning('off')
addpath(pathdef)
mpopt = mpoption;
mpopt.out.all = 0; % do not print anything
mpopt.verbose = 0;
version_LODF = 0 % 1: use decrease_reconfig_algo_LODF.m
                                  % 0: use decrease_reconfig_algo.m
distancePara = 8
combine3 = 1

candi_brch_bus = []; % candidate branch i added to bus j
% mpc0 = case136;
casei=4
d136_v03 
substation_node = 136;   n_bus = substation_node;

n1 = 3
n2 = 2
n1_down_substation = n1+1;    n2_up_ending = n2;

Branch0 = Branch;
brch_idx_in_loop0 = unique(brch_idx_in_loop(:));

% load_PV_24h_data
demand_PV_data.gen_type       = gen_type;
demand_PV_data.Gen_renew      = Gen_renew;
%% original network's power flow (not radial)
% show_biograph(Branch, Bus)
from_to = show_biograph_not_sorted(Branch, substation_node, 0); % zjp, should be 1
mpc = generate_mpc(Bus, Branch, n_bus);
loss0 = runpf_1hr(mpc, mpopt, demand_PV_data);
% res_orig = runpf(mpc, mpopt);
% losses = get_losses(res_orig.baseMVA, res_orig.bus, res_orig.branch);
% loss0 = sum(real(losses));
fprintf('case136_tabu: original loop network''s loss is %.5f \n\n', loss0)

% for each branch in a loop, 
% if open that branch does not cause isolation, check the two ending buses 
% of that branch for connectivity, realized by shortestpath or conncomp
% calculate the lowest loss increase, print out the sorted loss increase 
% open the branch with lowest loss increase
% stop criterion: number of buses - number of branches = 1

%% ------------------------ Core algorithm ------------------------%%
ff0 = Branch(:, 1);   ff = ff0;
tt0 = Branch(:, 2);   tt = tt0;
t1 = toc;
if version_LODF
    [Branch] = decrease_reconfig_algo_LODF(Bus, Branch, brch_idx_in_loop, ...
        ff0, tt0, substation_node, n_bus, loss0, distancePara); %%%  core algorithm
else
    [Branch] = decrease_reconfig_algo(Bus, Branch, brch_idx_in_loop, ff0, tt0, ...
        substation_node, n_bus, loss0); %%%  core algorithm
end
t2 = toc;
time_consumption.core = t2 - t1

% output of core algorithm
show_biograph = 0;
from_to = show_biograph_not_sorted(Branch(:, [1 2]), substation_node, ...
        0); % zjp should be 1
mpc = generate_mpc(Bus, Branch, n_bus);
t1 = toc;
loss0_dec = runpf_1hr(mpc, mpopt, demand_PV_data);
% res_pf_dec = runpf(mpc, mpopt);
% losses = get_losses(res_pf_dec.baseMVA, res_pf_dec.bus, res_pf_dec.branch);
% loss0_dec = sum(real(losses));  % 0.2960
t2 = toc;    
time_consumption.runpf = t2-t1;

fprintf('case136_tabu: radial network obtained by my core algorithm''s loss is %.5f \n\n', ...
    loss0_dec)
yij_dec = generate_yij_from_Branch(Branch, Branch0);

Branch_loss_record = [];
% record Branch and loss
Branch_loss_record.core.Branch = Branch;
Branch_loss_record.core.loss = loss0_dec;

%% prepare force open branches for tabu: branch_idx_focused

if get_brch_tabu_v2 == 1
[branch_idx_focused] = get_branch_idx_focused_for_tabu_v2( ...
    from_to, Branch0, Branch, substation_node, brch_idx_in_loop0, n_bus, ...
    n1_down_substation, n2_up_ending); % to answer reviewer 5-5's question
else
    [branch_idx_focused] = get_branch_idx_focused_for_tabu( ...
        from_to, Branch0, Branch, substation_node, brch_idx_in_loop0, n_bus, ...
        n1_down_substation, n2_up_ending);
end

% % [path_in_node] = find_path_to_substation(from_to, 382, substation_node, 1);
if debug_flag == 1
    branch_idx_focused = branch_idx_focused(1:2);
end
%% ------------------------ Tabu algorithm ------------------------%%
% run the core program for each upstream branch connected to the idx_force_open
for iter = 1:length(branch_idx_focused) % idx_force_open)
    fprintf('iter=%d/%d\n', iter, length(branch_idx_focused)); % idx_force_open));
    Branch = Branch0;
    Branch(branch_idx_focused(iter), :) = [];  
    % %     Branch(idx_force_open(iter), :) = [];
    ff0 = Branch(:, 1);   ff = ff0;
    tt0 = Branch(:, 2);   tt = tt0;
    
    brch_idx_in_loop = brch_idx_in_loop0;
    idx_tmp = find(brch_idx_in_loop == branch_idx_focused(iter));
% %     idx_tmp = find(brch_idx_in_loop == idx_force_open(iter));
    if isempty(idx_tmp)
    else
        brch_idx_in_loop(idx_tmp) = [];
        brch_idx_in_loop(idx_tmp:end) = brch_idx_in_loop(idx_tmp:end)-1;
    end

    t1 = toc;
    %%------------------- core algorithm in Tabu loop--------------------%%
    if version_LODF
        [Branch] = decrease_reconfig_algo_LODF(Bus, Branch, brch_idx_in_loop, ...
            ff0, tt0, substation_node, n_bus, loss0, distancePara); %%%  core algorithm
    else
        [Branch] = decrease_reconfig_algo(Bus, Branch, brch_idx_in_loop, ff0, tt0, ...
            substation_node, n_bus, loss0); %%%  core algorithm
    end
    t2 = toc;    
    time_consumption.tabu(iter) = t2-t1;
    
    from_to = show_biograph_not_sorted(Branch(:, [1 2]), substation_node, ...
        show_biograph); %%% show figure, take time
    mpc = generate_mpc(Bus, Branch, n_bus);
    t1 = toc;
    lossi = runpf_1hr(mpc, mpopt, demand_PV_data);
%     res_pf = runpf(mpc, mpopt);
%     losses = get_losses(res_pf.baseMVA, res_pf.bus, res_pf.branch);
%     lossi = sum(real(losses))  % loss = 0.2960
    t2 = toc;    
    time_consumption.runpf(iter) = t2-t1;
    
    loss_tabu(iter,1) = lossi;
    yij_dec = generate_yij_from_Branch(Branch, Branch0);
        
    % record Branch and loss
    Branch_loss_record.tabu(iter,1).Branch = Branch; 
    Branch_loss_record.tabu(iter,1).loss = lossi;

    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
      VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
%     Vm = res_pf.bus(:, VM)';
%     Va = res_pf.bus(:, VA)';
%     ending_bus = find_ending_node(Branch, substation_node);
%     [ending_bus'; Vm(ending_bus)];
%     % ending_bus = [6 14 72 22 24 83 41 42 32 33 37 55 63 8 9 10 62 71 13 82]';
%     % [ending_bus'; Vm(ending_bus)]
    
    %% ---------------------one open and one close---------------------%%
    % prepare nodes_focused for one_open_one_close
    t1 = toc;
    [nodes_focused] = get_nodes_focused_o1c1( ...
        from_to, Branch, Branch0, substation_node, brch_idx_in_loop, ...
        n1_down_substation, n2_up_ending);
    
    loss_before_switch0 = lossi;
    if combine3 
        [record_o1c1_loss_dec, loss_after_switch_combine_two_o1c1, Branch_loss] = ...
            one_open_one_close_combine3(nodes_focused, Bus, Branch0, Branch, from_to, ...
            substation_node, n_bus, loss_before_switch0);
    else
        [record_o1c1_loss_dec, loss_after_switch_combine_two_o1c1, Branch_loss] = ...
            one_open_one_close(nodes_focused, Bus, Branch0, Branch, from_to, ...
            substation_node, n_bus, loss_before_switch0);
    end
    t2 = toc;
    time_consumption.tabu_o1c1(iter) = t2-t1;
    
    % record Branch and loss
    Branch_loss_record.tabu_o1c1_dec{iter}.Branch = Branch_loss.Branch_o1c1_dec; 
%     Branch_loss_record.tabu_o1c1_dec(iter,1).Branch = Branch_loss.Branch_o1c1_dec; 
    Branch_loss_record.tabu_o1c1_dec{iter}.loss = Branch_loss.loss_o1c1_dec; 
    Branch_loss_record.tabu_combine_2_o1c1_dec{iter}.Branch = ...
        Branch_loss.Branch_after_switch_combine_two_o1c1; 
    Branch_loss_record.tabu_combine_2_o1c1_dec{iter}.loss = ...
        Branch_loss.loss_after_switch_combine_two_o1c1;     
    if combine3
        Branch_loss_record.tabu_combine_3_o1c1_dec{iter}.Branch = ...
            Branch_loss.Branch_after_switch_combine_three_o1c1; 
        Branch_loss_record.tabu_combine_3_o1c1_dec{iter}.loss = ...
            Branch_loss.loss_after_switch_combine_three_o1c1;     
    end
    
    min_loss_o1c1 = min(record_o1c1_loss_dec(:,1));
    fprintf('case136_tabu: minimum loss obtained after ''one open and one close'': %.5f\n', ...
        min_loss_o1c1);
    
    min_loss_combine_two_o1c1 = 1e9;
    fprintf('case136_tabu: loss obtained after combine two ''one open and one close'': \n')
    for i = 1:length(loss_after_switch_combine_two_o1c1)
        temp = min(loss_after_switch_combine_two_o1c1{i});
        if temp<min_loss_combine_two_o1c1
            min_loss_combine_two_o1c1 = temp;
        end
        fprintf(' %.5f \n', temp);
    end    
    fprintf('case136_tabu: minimum loss obtained after combine two ''one open and one close'': %.5f \n', ...
        min_loss_combine_two_o1c1)    
    
    %% ---------------------two open and two close---------------------%%
    flag_2o2c = 0
    if flag_2o2c == 1
        t1 = toc;
        loss_before_switch0 = lossi;
        [record_o2c2_loss_dec, loss_after_switch_combine_two_o2c2] = ...
            two_open_two_close(nodes_focused, Bus, Branch0, Branch, from_to, ...
            substation_node, n_bus, loss_before_switch0);
        t2 = toc;
        time_consumption.tabu_o2c2(iter) = t2-t1;
        
        min_loss_o2c2 = min(record_o2c2_loss_dec(:,1));
        fprintf('case136_tabu: minimum loss obtained after ''two open and two close'': %.5f\n', ...
            min_loss_o2c2);

        min_loss_combine_two_o2c2 = 1e9;
        fprintf('case136_tabu: loss obtained after combine two ''two open and two close'': \n')
        for i = 1:length(loss_after_switch_combine_two_o2c2)
            temp = min(loss_after_switch_combine_two_o2c2{i});
            if temp<min_loss_combine_two_o2c2
                min_loss_combine_two_o2c2 = temp;
            end
            fprintf(' %.5f \n', temp);
        end
        fprintf('case136_tabu: minimum loss obtained after combine two ''two open and two close'': %.5f \n', ...
            min_loss_combine_two_o2c2)  
        res_save{iter}.min_loss_o2c2 = min_loss_o2c2;
        res_save{iter}.min_loss_combine_two_o2c2 = min_loss_combine_two_o2c2;
    end

    res_save{iter}.yij_dec = yij_dec;
    res_save{iter}.Branch = Branch;
    res_save{iter}.lossi = lossi;
    res_save{iter}.record_o1c1_loss_dec = record_o1c1_loss_dec;
    res_save{iter}.min_loss_o1c1 = min_loss_o1c1;
    res_save{iter}.min_loss_combine_two_o1c1 = min_loss_combine_two_o1c1;
    
%     save(file_name, 'yij_dec', 'Branch', 'lossi');
    file_name = ['id', num2str(ver_num_reconfig_dec), ...
        '_case136_yij_Branch', '.mat'];
    save(file_name, 'res_save', 'branch_idx_focused', 'Branch_loss_record', ...
        'time_consumption');
end
file_name = ['id', num2str(ver_num_reconfig_dec), ...
    '_case136_yij_Branch', '.mat'];
save(file_name, 'res_save', 'branch_idx_focused', 'Branch_loss_record', ...
    'time_consumption');

% find_all_losses(Branch_loss_record);

fprintf('case136_tabu: losses obtained after applying tabu strategy: \n') % 0.28343  zjp 2018-1-18
fprintf('%.5f \n', loss_tabu)
fprintf('----- min: %.5f -----\n', min(loss_tabu))

min_loss = 1e9;
for i = 1:length(res_save)
    if min_loss>res_save{i}.min_loss_o1c1 
        min_loss = res_save{i}.min_loss_o1c1 ;
    end
    if min_loss>res_save{i}.min_loss_combine_two_o1c1 
        min_loss = res_save{i}.min_loss_combine_two_o1c1 ;
    end
end  
min_loss_o1c1 = min_loss

if flag_2o2c == 1
    min_loss = 1e9;
    for i = 1:length(res_save)
        if min_loss>res_save{i}.min_loss_o2c2 
            min_loss = res_save{i}.min_loss_o2c2 ;
        end
        if min_loss>res_save{i}.min_loss_combine_two_o2c2 
            min_loss = res_save{i}.min_loss_combine_two_o2c2 ;
        end
    end  
    min_loss_o2c2 = min_loss
end

%% compare to another result
if casei == 4
    idx_franco = [7, 35, 51, 90, 96, 106, 118, 126, 135, 137, 138, ...
        141, 142, 144, 145, 146, 147, 148, 150, 151, 155];
    selected_brch = [1:156];
    selected_brch(idx_franco) = [];
else
end
show_biograph_not_sorted(Branch0(selected_brch, [1 2]), substation_node, 0); % zjp should be 1
mpc = generate_mpc(Bus, Branch0(selected_brch, :), n_bus);
loss_franco = runpf_1hr(mpc, mpopt, demand_PV_data)
% res = runpf(mpc, mpopt);
% losses = get_losses(res.baseMVA, res.bus, res.branch);
% loss_franco = sum(real(losses)) % franco's result: 0.2802

% record Branch and loss
Branch_loss_record.franco.Branch = Branch0(selected_brch, :);
Branch_loss_record.franco.loss = loss_franco;

file_name = ['id', num2str(ver_num_reconfig_dec), ...
    '_case136_yij_Branch', '.mat'];
save(file_name, 'res_save', 'branch_idx_focused', 'Branch_loss_record', ...
    'time_consumption');

fprintf('\n')
ver_num_reconfig_dec