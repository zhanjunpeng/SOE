function [record_o1c1_loss_dec, loss_after_switch_combine_two_o1c1, Branch_loss] = ...
    one_open_one_close_combine3(nodes_focused, Bus, Branch0, Branch, from_to, ...
    substation_node, n_bus, loss_before_switch0)
% modified from one_open_one_close.m

%% one open and one close
record_o1c1 = [];
cnt = 0; Branch_o1c1 = []; loss_o1c1 = [];

%     mpopt = mpoption;
%     mpopt.out.all = 0; % do not print anything
%     mpopt.verbose = 0;    
% %% obtain the loss before switch
%     mpc = generate_mpc(Bus, Branch, n_bus);
%     res_pf = runpf(mpc, mpopt);
%     losses = get_losses(res_pf.baseMVA, res_pf.bus, res_pf.branch);
%     loss_before_switch = sum(real(losses));  % cannot be deleted, need to be used for comparison
    
    
for i = 1:length(nodes_focused)
    fprintf('i=%d/%d, ', i,length(nodes_focused));
    input_node = nodes_focused(i);
    [current_connection, other_possible_connections] = ...
        find_all_switch(Branch0, Branch, from_to, input_node);
    for j = 1:size(other_possible_connections,1)
        open_connection = current_connection(1,:); 
        close_connection = other_possible_connections(j,:);
        is_radial = 1;
%         is_radial = check_radiality(Bus, Branch0, Branch, ...
%             open_connection, close_connection);
        if is_radial
%             [loss_after_switch, loss_before_switch, Branch_out] = ...
            [loss_after_switch, Branch_out] = ...
                find_loss_change(Bus, Branch0, Branch, ...
                open_connection, close_connection, substation_node, ...
                n_bus);
            loss_before_switch = loss_before_switch0;
%             is_equal = isequal(loss_before_switch0, loss_before_switch) % zjp 2018-1-25
            if loss_after_switch <= loss_before_switch
                loss_not_inc = 1;
            else
                loss_not_inc = 0;
            end
            cnt = cnt+1;
            record_o1c1 = [ record_o1c1; [loss_after_switch, loss_before_switch, ...
                close_connection, open_connection, loss_not_inc] ];
            Branch_o1c1{cnt} = Branch_out;
            loss_o1c1(cnt,1) = loss_after_switch;
        end
    end
end
fprintf('\n')

%% obtain rows of record_o1c1 with decrease losses
idx00 = find(record_o1c1(:,end)==1);
record_o1c1_loss_dec = record_o1c1(idx00,:); % the rows with lower losses

Branch_o1c1_dec = Branch_o1c1(idx00);
loss_o1c1_dec = loss_o1c1(idx00);

% record Branch and loss
Branch_loss.Branch_o1c1_dec = Branch_o1c1_dec;
Branch_loss.loss_o1c1_dec = loss_o1c1_dec;

%% post processing for one open and one close
% idx_loss_not_inc = find(record_o1c1(:,end)==1);
% open_connection = record_o1c1(idx_loss_not_inc, [5 6]);
% close_connection = record_o1c1(idx_loss_not_inc, [3 4]);
% [loss_after_switch1, loss_before_switch1, Branch_out] = ...
%     find_loss_change(Bus, Branch0, Branch, ...
% open_connection, close_connection, substation_node)

%% add zone information for each row of record_o1c1
% zone information refer to 'which feeder is involved'
[first_downstream_node] = find_downstream(from_to, substation_node);

num_feeders = length(first_downstream_node);
for i = 1:num_feeders
    [first_downstream_node_temp, all_downstream_node] = ...
        find_downstream(from_to, first_downstream_node(i));
    feeder_nodes{i} = [first_downstream_node(i); all_downstream_node];
end

in_feeder = [];
for i = 1:size(record_o1c1_loss_dec)
    in_feeder(i,1) = find_feeder(feeder_nodes, record_o1c1_loss_dec(i,3));
    in_feeder(i,2) = find_feeder(feeder_nodes, record_o1c1_loss_dec(i,4));
end

% last two columns: which feeders are involved
record_o1c1_loss_dec(:,end+1:end+2) = in_feeder;


%% according to the feeder type i.e., record_o1c1_loss_dec(i, end-1:end), 
% assign type id to each row of record_o1c1_loss_dec
zone_involved_o1c1 = [];
zone_type_o1c1 = [];
type_cnt = 1;
for i = 1:size(record_o1c1_loss_dec,1)
    record_o1c1_loss_dec(i, end-1:end) = sort(record_o1c1_loss_dec(i, end-1:end));    
    if i==1
        zone_involved_o1c1{1} = unique(record_o1c1_loss_dec(i, end-1:end));
        zone_type_o1c1(i,1) = type_cnt;
    else
        temp0 = unique(record_o1c1_loss_dec(i, end-1:end));
        flag =0;
        for j = 1:length(zone_involved_o1c1)
            if isequal(zone_involved_o1c1{j}, temp0)
                zone_type_o1c1(i,1) = j;
                flag = 1;
                break;
            end
        end
        if flag==0
            type_cnt = type_cnt+1;
            zone_involved_o1c1{type_cnt} = temp0;
            zone_type_o1c1(i,1) = type_cnt;
        end
    end            
end

% output the zone_involved_o1c1
for i = 1:length(zone_involved_o1c1)
    zone_involved_o1c1{i}
end

% Example
% zone_involved_o1c1 = 
%      2     8
%      7     8
%      3     7
%      5     8

% combis =
%      1     3
%      3     4
     

%% combine two 'open one close one' together to see whether loss can be reduced

% put type i of 'open one close one' and type j of 'open one close one'
% together in combis if they can be combined together
combis = [];
for i = 1:length(zone_involved_o1c1)
    for j = (i+1):length(zone_involved_o1c1)
%         if i~=j
        l1 = length(unique([zone_involved_o1c1{i}, zone_involved_o1c1{j}]));
        l2 = length(unique([zone_involved_o1c1{i}]));
        l3 = length(unique([zone_involved_o1c1{j}]));
        if l1==(l2+l3)
            combis = [combis; [i j]];
        end
    end
end

Branch_after_switch_combine_two_o1c1 = [];
loss_after_switch_combine_two_o1c1 = [];
for i = 1:size(combis,1)
    combi = combis(i,:);
    [loss_after_switch, Branch_out] = find_loss_change_of_combine_two_o1c1( ...
        record_o1c1_loss_dec, zone_type_o1c1, combi, ...
        Bus, Branch0, Branch, substation_node, n_bus, loss_before_switch0);
    Branch_after_switch_combine_two_o1c1{i} = Branch_out;
    loss_after_switch_combine_two_o1c1{i} = loss_after_switch;
    min(loss_after_switch)
end
% ans =    0.2888
% ans =    0.2948

%% combine three 'open one close one' together to see whether loss can be reduced

combis = [];
for i = 1:length(zone_involved_o1c1)
    for j = (i+1):length(zone_involved_o1c1)
        for k = (j+1):length(zone_involved_o1c1)
%         if i~=j
            l1 = length(unique([zone_involved_o1c1{i}, zone_involved_o1c1{j}, zone_involved_o1c1{k}]));
            l2 = length(unique([zone_involved_o1c1{i}]));
            l3 = length(unique([zone_involved_o1c1{j}]));
            l4 = length(unique([zone_involved_o1c1{k}]));
            if l1==(l2+l3+l4)
                combis = [combis; [i j k]];
%                 fprintf('combis\n')
            end
        end
    end
end
Branch_after_switch_combine_three_o1c1 = [];
loss_after_switch_combine_three_o1c1 = [];
for i = 1:size(combis,1)
    combi = combis(i,:);
    [loss_after_switch, Branch_out] = find_loss_change_of_combine_three_o1c1( ...
        record_o1c1_loss_dec, zone_type_o1c1, combi, ...
        Bus, Branch0, Branch, substation_node, n_bus, loss_before_switch0);
    Branch_after_switch_combine_three_o1c1{i} = Branch_out;
    loss_after_switch_combine_three_o1c1{i} = loss_after_switch;
    min(loss_after_switch)
end


%% combine four 'open one close one' together to see whether loss can be reduced

combis = [];
for i = 1:length(zone_involved_o1c1)
    for j = (i+1):length(zone_involved_o1c1)
        for k = (j+1):length(zone_involved_o1c1)
            for kk = (j+1):length(zone_involved_o1c1)
    %         if i~=j
                l1 = length(unique([zone_involved_o1c1{i}, zone_involved_o1c1{j}, zone_involved_o1c1{k}, zone_involved_o1c1{kk}]));
                l2 = length(unique([zone_involved_o1c1{i}]));
                l3 = length(unique([zone_involved_o1c1{j}]));
                l4 = length(unique([zone_involved_o1c1{k}]));
                l5 = length(unique([zone_involved_o1c1{kk}]));
                if l1==(l2+l3+l4+l5)
                    combis = [combis; [i j k kk]];
%                     fprintf('combis\n')
                end
            end
        end
    end
end
Branch_after_switch_combine_four_o1c1 = [];
loss_after_switch_combine_four_o1c1 = [];
for i = 1:size(combis,1)
    combi = combis(i,:);
    [loss_after_switch, Branch_out] = find_loss_change_of_combine_four_o1c1( ...
        record_o1c1_loss_dec, zone_type_o1c1, combi, ...
        Bus, Branch0, Branch, substation_node, n_bus, loss_before_switch0);
    Branch_after_switch_combine_four_o1c1{i} = Branch_out;
    loss_after_switch_combine_four_o1c1{i} = loss_after_switch;
    min(loss_after_switch)
end


%% record Branch and loss
Branch_loss.Branch_after_switch_combine_two_o1c1 = ...
                      Branch_after_switch_combine_two_o1c1;
Branch_loss.loss_after_switch_combine_two_o1c1 = ...
                      loss_after_switch_combine_two_o1c1;
Branch_loss.Branch_after_switch_combine_three_o1c1 = ...
                      Branch_after_switch_combine_three_o1c1;
Branch_loss.loss_after_switch_combine_three_o1c1 = ...
                       loss_after_switch_combine_three_o1c1;
Branch_loss.Branch_after_switch_combine_four_o1c1 = ...
                      Branch_after_switch_combine_four_o1c1;
Branch_loss.loss_after_switch_combine_four_o1c1 = ...
                       loss_after_switch_combine_four_o1c1;

end
