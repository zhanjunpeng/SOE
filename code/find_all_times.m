function find_all_times(time_consumption, tabu_flag, n_bus)
    t_sum = 0;
    if tabu_flag
        fprintf('case%d_tabu: core time: %.4f \n', n_bus, time_consumption.core)
        t_sum = t_sum + time_consumption.core;
    else
        fprintf('case%d: core time: %.4f \n', n_bus, time_consumption.core)
        t_sum = t_sum + time_consumption.core;
    end
    
    if isfield(time_consumption, 'tabu')
        min_tabu = min(time_consumption.tabu);
        max_tabu = max(time_consumption.tabu);
        mean_tabu = mean(time_consumption.tabu);
        if tabu_flag
            fprintf('case%d_tabu: tabu_core min/max/mean time: %.4f/%.4f/%.4f \n', ...
                n_bus, min_tabu, max_tabu, mean_tabu)
            t_sum = t_sum + mean_tabu;
%         else
%             fprintf('case%d: tabu_core time: %.4f \n', n_bus, time_consumption.core)
        end
    end
    
    if isfield(time_consumption, 'runpf')
        min_runpf = min(time_consumption.runpf);
        max_runpf = max(time_consumption.runpf);
        mean_runpf = mean(time_consumption.runpf);
        if tabu_flag
            fprintf('case%d_tabu: runpf min/max/mean time: %.4f/%.4f/%.4f \n', ...
                n_bus, min_runpf, max_runpf, mean_runpf)
        else
            fprintf('case%d: runpf min/max/mean time: %.4f/%.4f/%.4f \n', ...
                n_bus, min_runpf, max_runpf, mean_runpf)
        end
    end
    
    
    if isfield(time_consumption, 'tabu_o1c1')
        min_tabu_o1c1 = min(time_consumption.tabu_o1c1);
        max_tabu_o1c1 = max(time_consumption.tabu_o1c1);
        mean_tabu_o1c1 = mean(time_consumption.tabu_o1c1);
        if tabu_flag
            fprintf('case%d_tabu: tabu_o1c1 min/max/mean time: %.4f/%.4f/%.4f \n', ...
                n_bus, min_tabu_o1c1, max_tabu_o1c1, mean_tabu_o1c1)
            t_sum = t_sum + mean_tabu_o1c1;
        else
            fprintf('case%d: o1c1 time: %.4f \n', ...
                n_bus, mean_tabu_o1c1)
            t_sum = t_sum + mean_tabu_o1c1;
        end
    end
    
    if isfield(time_consumption, 'tabu_o2c2')
        min_tabu_o2c2 = min(time_consumption.tabu_o2c2);
        max_tabu_o2c2 = max(time_consumption.tabu_o2c2);
        mean_tabu_o2c2 = mean(time_consumption.tabu_o2c2);
        if tabu_flag
            fprintf('case%d_tabu: tabu_o2c2 min/max/mean time: %.4f/%.4f/%.4f \n', ...
                n_bus, min_tabu_o2c2, max_tabu_o2c2, mean_tabu_o2c2)
            t_sum = t_sum + mean_tabu_o2c2;
        else
            fprintf('case%d: o2c2 time: %.4f \n', ...
                n_bus, mean_tabu_o2c2)
            t_sum = t_sum + mean_tabu_o2c2;
        end
    end
    fprintf('case%d: total time: %.4f \n', n_bus, t_sum)

end