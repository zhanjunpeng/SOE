function [losses_1hr] = runpf_1hr(mpc, mpopt, demand_PV_data)

gen_type = demand_PV_data.gen_type;
Gen_renew = demand_PV_data.Gen_renew;

if (~isempty(Gen_renew))
    if gen_type
        for i = 1:size(Gen_renew, 1)  % DG treated as negative load
            idx = find(mpc.bus(:,1)==Gen_renew(i,1));
%                 Bus(idx,2) = Bus(idx,2) - Gen_renew(i, 2) * PV_profile(tt);
            mpc.bus(idx,3) = mpc.bus(idx,3) - Gen_renew(i, 2)/1000 * 1;
            mpc.bus(idx,4) = mpc.bus(idx,4) - Gen_renew(i, 3)/1000 * 1;
        end    
    end
end

res = runpf(mpc, mpopt);
losses = get_losses(res.baseMVA, res.bus, res.branch);
losses_1hr = sum(real(losses));