function [] = show_yij_loss_difference( ...
    yij_franco, Branch_loss_record, tabu_flag, type0, n_bus, Branch0)
% generate figure: loss vs. number of branches changed
% 
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

%% obtain all the yij

cnt_all = 1;
%% block 1
fprintf('case%d_tabu loss: radial network obtained by my core algorithm''s loss is %.5f \n', ...
    n_bus, Branch_loss_record.core.loss)
loss_all(cnt_all,1) = Branch_loss_record.core.loss;
Branch_all{cnt_all} = Branch_loss_record.core.Branch;
cnt_all = cnt_all+1;

%% block 2
if tabu_flag
    loss_tmp = [];
    for i = 1:length(Branch_loss_record.tabu)
        loss_all(cnt_all,1) = Branch_loss_record.tabu(i).loss; %%
        Branch_all{cnt_all} = Branch_loss_record.tabu(i).Branch;
        cnt_all = cnt_all+1;
    end
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
            if isempty(tabu_o1c1_dec_temp)
                min_loss_tabu_o1c1(i,1) = 1e6;
                min_Branch_tabu_o1c1{i} = 1e6;
            else
                len_tmp = length(Branch_loss_record.tabu_o1c1_dec{i}.loss);
                Brch_temp = Branch_loss_record.tabu_o1c1_dec{i}.Branch;
                for ii = 1:len_tmp
                    loss_all(cnt_all,1) = Branch_loss_record.tabu_o1c1_dec{i}.loss(ii); %%
                    Branch_all{cnt_all} = Brch_temp{ii};
                    cnt_all = cnt_all+1;
                end                
%                 [min_loss, min_idx] = min(tabu_o1c1_dec_temp.loss);
%                 min_loss_tabu_o1c1(i,1) = min_loss;
%                 Brch_temp = Branch_loss_record.tabu_o1c1_dec{i}.Branch;
%                 min_Branch_tabu_o1c1{i} = Brch_temp{min_idx};
            end
        end
%         [min_loss3, min_idx] = min(min_loss_tabu_o1c1);
%         fprintf('case%d_tabu loss: tabu + o1c1 is %.5f \n', n_bus, min_loss3);
%         Branch3 = min_Branch_tabu_o1c1{min_idx};
    else
        len_tmp = length(Branch_loss_record.tabu_o1c1_dec.loss);        
        for ii = 1:len_tmp
            loss_all(cnt_all,1) = Branch_loss_record.tabu_o1c1_dec.loss(ii); %%
            Branch_all{cnt_all} = Branch_loss_record.tabu_o1c1_dec.Branch{ii};
            cnt_all = cnt_all+1;
        end        
%         [min_loss3, min_idx] = min(Branch_loss_record.tabu_o1c1_dec.loss);
%         if type0 == 3
%             Branch_temp = Branch_loss_record.tabu_o1c1_dec.Branch;
%             Branch3 = Branch_temp{min_idx};
%         else
%             Branch_temp = Branch_loss_record.tabu_o1c1_dec(min_idx).Branch;
%             Branch3 = Branch_temp{min_idx};
%         end
%         fprintf('case%d_tabu loss: tabu + o1c1 is %.5f \n', n_bus, min_loss3);
    end
%     loss3 = min_loss3;
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

    fprintf('number of terms in block 4 is %d\n', length(loss4s))
    for ii = 1:length(loss4s)
        loss_all(cnt_all,1) = loss4s(ii);
        Branch_all{cnt_all} = Branch4s{ii};
        cnt_all = cnt_all+1;
    end


%     [min_loss4, min_idx] = min(loss4s);
%     fprintf('case%d_tabu loss: tabu + combine_2_o1c1 is %.5f \n', n_bus, min_loss4);
%     loss4 = min_loss4;
%     if isempty(min_idx)
%         Branch4 = [];
%     else
%         Branch4 = Branch4s{min_idx};
%     end
else
    loss4 = 1e6;
    Branch4 = 1e6;
end


%% --------------------------------------------------------------------
%  calculate how many branches of yij are different from yij_franco
%  and plot loss vs. number of branches of yij that are different from yij_franco
%% --------------------------------------------------------------------
nn = length(loss_all)
for ii = 1:nn
%     loss_all(ii)
    yij = generate_yij_from_Branch(Branch_all{ii}, Branch0);
    yij_all(:,ii) = yij(:);
    number_of_different_branches(ii, 1) = length(find(yij-yij_franco));
end
figure
plot(number_of_different_branches, loss_all, '.k')
xlabel('Number of different branches')
ylabel('Loss')


end