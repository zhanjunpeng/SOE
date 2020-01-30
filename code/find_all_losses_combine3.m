function [Branch_4blk, loss_4blk] = ...
    find_all_losses_combine3(Branch_loss_record, tabu_flag, type0, n_bus)
% output the minimum loss in each stage, and all the losses

% % record Branch and loss
% Branch_loss_record.core.Branch = Branch;
% Branch_loss_record.core.loss = loss0_dec;
% 
%     % record Branch and loss
%     Branch_loss_record.tabu(iter,1).Branch = Branch; 
%     Branch_loss_record.tabu(iter,1).loss = lossi;
%     
%     % record Branch and loss
%     Branch_loss_record.tabu_o1c1_dec(iter,1).Branch = Branch_loss.Branch_o1c1_dec; 
%     Branch_loss_record.tabu_o1c1_dec(iter,1).loss = Branch_loss.loss_o1c1_dec; 
%     
%     Branch_loss_record.tabu_combine_2_o1c1_dec(iter,1).Branch = ...
%         Branch_loss.Branch_after_switch_combine_two_o1c1; 
%     Branch_loss_record.tabu_combine_2_o1c1_dec(iter,1).loss = ...
%         Branch_loss.loss_after_switch_combine_two_o1c1;   

%% block 1
fprintf('case%d_tabu loss: radial network obtained by my core algorithm''s loss is %.10f \n', ...
    n_bus, Branch_loss_record.core.loss)
loss1 = Branch_loss_record.core.loss;
Branch1 = Branch_loss_record.core.Branch;

%% block 2
if tabu_flag
    loss_tmp = [];
    for i = 1:length(Branch_loss_record.tabu)
        loss_tmp(i,1) = Branch_loss_record.tabu(i).loss;
    end
    [min_loss_tabu, min_idx] = min(loss_tmp);
    loss2 = min_loss_tabu;
    % min_loss_tabu
    fprintf('case%d_tabu loss: tabu is %.10f \n', n_bus, min_loss_tabu);
    Branch2 = Branch_loss_record.tabu(min_idx,1).Branch;
else
    loss2 = 1e6;
    Branch2 = 1e6;
end

%% block 3
min_Branch_tabu_o1c1 = [];
Branch3 = [];
min_loss_tabu_o1c1 = [];
if isfield(Branch_loss_record, 'tabu_o1c1_dec')
    if iscell(Branch_loss_record.tabu_o1c1_dec)
        for i = 1:length(Branch_loss_record.tabu_o1c1_dec)
            tabu_o1c1_dec_temp = Branch_loss_record.tabu_o1c1_dec{i};
            if (isempty(tabu_o1c1_dec_temp) | isempty(tabu_o1c1_dec_temp.Branch))
                min_loss_tabu_o1c1(i,1) = 1e6;
                min_Branch_tabu_o1c1{i} = 1e6;
            else
                [min_loss, min_idx] = min(tabu_o1c1_dec_temp.loss);
                min_loss_tabu_o1c1(i,1) = min_loss;
                Brch_temp = Branch_loss_record.tabu_o1c1_dec{i}.Branch;
                min_Branch_tabu_o1c1{i} = Brch_temp{min_idx};
            end
        end
        [min_loss3, min_idx] = min(min_loss_tabu_o1c1);
        fprintf('case%d_tabu loss: tabu + o1c1 is %.10f \n', n_bus, min_loss3);
        Branch3 = min_Branch_tabu_o1c1{min_idx};
    else
        [min_loss3, min_idx] = min(Branch_loss_record.tabu_o1c1_dec.loss);
        if type0 == 3
            Branch_temp = Branch_loss_record.tabu_o1c1_dec.Branch;
            Branch3 = Branch_temp{min_idx};
        else
            Branch_temp = Branch_loss_record.tabu_o1c1_dec(min_idx).Branch;
            Branch3 = Branch_temp{min_idx};
        end
        fprintf('case%d_tabu loss: tabu + o1c1 is %.10f \n', n_bus, min_loss3);
    end
    loss3 = min_loss3;
else
    loss3 = 1e6;
    Branch3 = 1e6;
end

%% block 4
loss4s = [];
Branch4s = [];
cnt = 0;
if isfield(Branch_loss_record, 'tabu_combine_2_o1c1_dec')
    if iscell(Branch_loss_record.tabu_combine_2_o1c1_dec)
        for i = 1:length(Branch_loss_record.tabu_combine_2_o1c1_dec)
            tabu_combine_2_o1c1_dec_temp = ...
                Branch_loss_record.tabu_combine_2_o1c1_dec{i};
            if isempty(tabu_combine_2_o1c1_dec_temp)            
            else
                lossi = Branch_loss_record.tabu_combine_2_o1c1_dec{i}.loss;
                Branchi = Branch_loss_record.tabu_combine_2_o1c1_dec{i}.Branch;
            %     lossi = Branch_loss_record.tabu_combine_2_o1c1_dec(i).loss;
            %     Branchi = Branch_loss_record.tabu_combine_2_o1c1_dec(i).Branch;
                for j = 1:length(lossi)
            %         lossj = cell2mat(lossi(j));
                    lossj = lossi{j};
                    loss4s = [loss4s; lossj];
                    Branchj = Branchi{j};
                    for k = 1:length(Branchj)
                        cnt = cnt+1;
                        Branch4s{cnt} = Branchj{k};
                    end
                end
            end
        end    
    else
        if isempty(Branch_loss_record.tabu_combine_2_o1c1_dec.Branch)
        else
            loss_temp = Branch_loss_record.tabu_combine_2_o1c1_dec.loss;
            Branch_temp = Branch_loss_record.tabu_combine_2_o1c1_dec.Branch;
            for i = 1:length(loss_temp)
                loss4s = [loss4s; loss_temp{i}];
                Branch_tempi = Branch_temp{i};
                for j = 1:length(Branch_tempi)
                    cnt = cnt+1;
                    Branch4s{cnt} = Branch_tempi{j};
                end
            end
        end
    end

    [min_loss4, min_idx] = min(loss4s);
    fprintf('case%d_tabu loss: tabu + combine_2_o1c1 is %.10f \n', n_bus, min_loss4);
    loss4 = min_loss4;
    if isempty(min_idx)
        Branch4 = [];
    else
        Branch4 = Branch4s{min_idx};
    end
else
    loss4 = 1e6;
    Branch4 = 1e6;
end

%% block 5
loss5s = [];
Branch5s = [];
cnt = 0;
if isfield(Branch_loss_record, 'tabu_combine_3_o1c1_dec')
    if iscell(Branch_loss_record.tabu_combine_3_o1c1_dec)
        for i = 1:length(Branch_loss_record.tabu_combine_3_o1c1_dec)
            tabu_combine_3_o1c1_dec_temp = ...
                Branch_loss_record.tabu_combine_3_o1c1_dec{i};
            if isempty(tabu_combine_3_o1c1_dec_temp)            
            else
                lossi = Branch_loss_record.tabu_combine_3_o1c1_dec{i}.loss;
                Branchi = Branch_loss_record.tabu_combine_3_o1c1_dec{i}.Branch;
            %     lossi = Branch_loss_record.tabu_combine_3_o1c1_dec(i).loss;
            %     Branchi = Branch_loss_record.tabu_combine_3_o1c1_dec(i).Branch;
                for j = 1:length(lossi)
            %         lossj = cell2mat(lossi(j));
                    lossj = lossi{j};
                    loss5s = [loss5s; lossj];
                    Branchj = Branchi{j};
                    for k = 1:length(Branchj)
                        cnt = cnt+1;
                        Branch5s{cnt} = Branchj{k};
                    end
                end
            end
        end    
    else
        if isempty(Branch_loss_record.tabu_combine_3_o1c1_dec.Branch)
        else
            loss_temp = Branch_loss_record.tabu_combine_3_o1c1_dec.loss;
            Branch_temp = Branch_loss_record.tabu_combine_3_o1c1_dec.Branch;
            for i = 1:length(loss_temp)
                loss5s = [loss5s; loss_temp{i}];
                Branch_tempi = Branch_temp{i};
                for j = 1:length(Branch_tempi)
                    cnt = cnt+1;
                    Branch5s{cnt} = Branch_tempi{j};
                end
            end
        end
    end

    [min_loss5, min_idx] = min(loss5s);
    fprintf('case%d_tabu loss: tabu + combine_3_o1c1 is %.10f \n', n_bus, min_loss5);
    loss5 = min_loss5;
    if isempty(min_idx)
        Branch5 = [];
    else
        Branch5 = Branch5s{min_idx};
    end
else
    loss5 = 1e6;
    Branch5 = 1e6;
end

%% block 6
loss6s = [];
Branch6s = [];
cnt = 0;
if isfield(Branch_loss_record, 'tabu_combine_4_o1c1_dec')
    if iscell(Branch_loss_record.tabu_combine_4_o1c1_dec)
        for i = 1:length(Branch_loss_record.tabu_combine_4_o1c1_dec)
            tabu_combine_4_o1c1_dec_temp = ...
                Branch_loss_record.tabu_combine_4_o1c1_dec{i};
            if isempty(tabu_combine_4_o1c1_dec_temp)            
            else
                lossi = Branch_loss_record.tabu_combine_4_o1c1_dec{i}.loss;
                Branchi = Branch_loss_record.tabu_combine_4_o1c1_dec{i}.Branch;
            %     lossi = Branch_loss_record.tabu_combine_4_o1c1_dec(i).loss;
            %     Branchi = Branch_loss_record.tabu_combine_4_o1c1_dec(i).Branch;
                for j = 1:length(lossi)
            %         lossj = cell2mat(lossi(j));
                    lossj = lossi{j};
                    loss6s = [loss6s; lossj];
                    Branchj = Branchi{j};
                    for k = 1:length(Branchj)
                        cnt = cnt+1;
                        Branch6s{cnt} = Branchj{k};
                    end
                end
            end
        end    
    else
        if isempty(Branch_loss_record.tabu_combine_4_o1c1_dec.Branch)
        else
            loss_temp = Branch_loss_record.tabu_combine_4_o1c1_dec.loss;
            Branch_temp = Branch_loss_record.tabu_combine_4_o1c1_dec.Branch;
            for i = 1:length(loss_temp)
                loss6s = [loss6s; loss_temp{i}];
                Branch_tempi = Branch_temp{i};
                for j = 1:length(Branch_tempi)
                    cnt = cnt+1;
                    Branch6s{cnt} = Branch_tempi{j};
                end
            end
        end
    end

    [min_loss6, min_idx] = min(loss6s);
    fprintf('case%d_tabu loss: tabu + combine_4_o1c1 is %.10f \n', n_bus, min_loss6);
    loss6 = min_loss6;
    if isempty(min_idx)
        Branch6 = [];
    else
        Branch6 = Branch6s{min_idx};
    end
else
    loss6 = 1e6;
    Branch6 = 1e6;
end

%% output
Branch_4blk{1} = Branch1;
Branch_4blk{2} = Branch2;
Branch_4blk{3} = Branch3;
if ~isempty(Branch4)
    Branch_4blk{4} = Branch4;
end
if ~isempty(Branch5)
    Branch_4blk{5} = Branch5;
end
if ~isempty(Branch6)
    Branch_4blk{6} = Branch6;
end

loss_4blk(1) = loss1;
loss_4blk(2) = loss2;
loss_4blk(3) = loss3;
if ~isempty(loss4)
    loss_4blk(4) = loss4;
end
if ~isempty(loss5)
    loss_4blk(5) = loss5;
end
if ~isempty(loss6)
    loss_4blk(6) = loss6;
end

end