function mpc = generate_mpc(Bus, Branch, caseNum)
Gen_renew = [];
% d84
% Bus = Bus([84 1:83], :); % ---------------------------------------------
if caseNum == 33
    nref  = 1;          % n?de referência
    vref  = 1.0;        % tensão na subestação (pu)
    vbase = 12.66;      % Tensão base (kV)
    sbase = 1000;       % Potência base (kVA)
    tol   = 10^-8;      % Tolerância do erro permitida
    vmin  = 0.90;       % Tensão mínima (pu)
    vmax  = 1.00;       % Tensão máxima (pu)
    zbase = 1000*((vbase^2)/sbase);
elseif caseNum == 84
%     Bus = Bus([end 1:(end-1)], :);
    nref  = 84;         % n?de referência
    vref  = 1.0;        % tensão na subestação (pu)
    vbase = 11.40;      % Tensão base (kV)
    sbase = 10000;      % Potência base (kVA)
    tol   = 10^-8;      % Tolerância do erro permitida
    vmin  = 0.95;       % Tensão mínima (pu)
    vmax  = 1.00;       % Tensão máxima (pu)
    zbase = 1000*((vbase^2)/sbase);
elseif caseNum == 119
    nref  = 1;         % n?de referência
    vref  = 1.0;        % tensão na subestação (pu)
    vbase = 11.0;      % Tensão base (kV)
    sbase = 10000;      % Potência base (kVA)
    tol   = 10^-8;      % Tolerância do erro permitida
    vmin  = 0.80;       % Tensão mínima (pu)
    vmax  = 1.00;       % Tensão máxima (pu)
    zbase = 1000*((vbase^2)/sbase);
elseif caseNum == 136
    nref  = 136;        % n?de referência
    vref  = 1.0;        % tensão na subestação (pu)
    vbase = 13.8;       % Tensão base (kV)
    % sbase = 100000;     % Potência base (kVA)
    tol   = 10^-8;      % Tolerância do erro permitida
    vmin  = 0.95;       % Tensão mínima (pu)
    vmax  = 1;       % Tensão máxima (pu)
    % vmin  = 0.93       % Tensão mínima (pu)
    % vmax  = 1.05       % Tensão máxima (pu)
elseif caseNum == 417    
    nref  = 1;          % n?de referência
    vref  = 1.0;        % tensão na subestação (pu)
    vbase = 10.0;       % Tensão base (kV)
    sbase = 100000;     % Potência base (kVA)
    tol   = 10^-8;      % Tolerância do erro permitida
    vmin  = 0.95;       % Tensão mínima (pu)
    vmax  = 1.0;       % Tensão máxima (pu)
    zbase = 1000*((vbase^2)/sbase);
else
    fprintf('error in generate_mpc.m \n');
    error
end

nb = size(Bus, 1);
nl = size(Branch, 1);
baseMVA = 1;
%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = baseMVA;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
% mpc.bus = [
% 	1	3	0	0	0	0	1	1	0	345	1	1.1	0.9;
% 	2	2	0	0	0	0	1	1	0	345	1	1.1	0.9;
% 	3	2	0	0	0	0	1	1	0	345	1	1.1	0.9;
% ];
mpc.bus = zeros(nb, 13);
mpc.bus(:,1) = Bus(:,1);
mpc.bus(:,2) = [3; ones(nb-1,1)];
% mpc.bus(:,2) = [ones(nb-1,1); 3];
mpc.bus(:,[3 4]) = Bus(:, [2 3])/1000; % in MW
% mpc.bus(:,[5:13]) = repmat([0	0	1	1.05	0	13.8	1	1.1	0.9], 136, 1);
mpc.bus(:,[5:13]) = repmat([0	0	1	vmax	0	vbase	1	vmax  vmin], nb, 1);
% mpc.bus(:,[5:13]) = repmat([0	0	1	1.05	0	vbase	1	vmax  vmin], 136, 1);

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	Bus(1,1)	0	0 3000 -3000	vmax	baseMVA	1  250	0	0	0	0	0	0	0	0	0	0	0	0;
% 	Bus(end,1)	0	0 3000 -3000	vmax	baseMVA	1  250	0	0	0	0	0	0	0	0	0	0	0	0;
% 	136	0	0 3000 -3000	1.05	100	1  25	1	0	0	0	0	0	0	0	0	0	0	0;
% 	2	163	0	300	-300	1	100	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
% 	3	85	0	300	-300	1	100	1	270	10	0	0	0	0	0	0	0	0	0	0	0;
];
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
if isempty(Gen_renew)
else
    nrow = size(Gen_renew, 1);
    for i = 1:size(Gen_renew, 1)  % DG treated as negative load
        mpc.bus(Gen_renew(i, 1), PD) = ...
            mpc.bus(Gen_renew(i, 1), PD) - Gen_renew(i, 2)/1000;
        mpc.bus(Gen_renew(i, 1), QD) = ...
            mpc.bus(Gen_renew(i, 1), QD) - Gen_renew(i, 3)/1000;
    end
%     mpc.gen([2:1+nrow], :) = repmat([Bus(end,1)	0	0 3000 -3000	vmax	baseMVA	1  250	0	0	0	0	0	0	0	0	0	0	0	0], nrow, 1)
%     mpc.gen([2:1+nrow], GEN_BUS) = Gen_renew(:,1);    % bus index
%     mpc.gen([2:1+nrow], PMAX) = Gen_renew(:,2)/1000;  % in MW
%     mpc.gen([2:1+nrow], QMAX) = Gen_renew(:,3)/1000;  % in MVar
%     mpc.gen([2:1+nrow], QMIN) = -Gen_renew(:,3)/1000; % in MVar
%     mpc.gen([2:1+nrow], PG)   = Gen_renew(:,2)/10/1000; % in MW
%     mpc.gen([2:1+nrow], QG)   = Gen_renew(:,3)/10/1000; % in MVar
end
mpc.gen(1, 2) = sum(mpc.bus(:, 3));
mpc.gen(1, 3) = sum(mpc.bus(:, 4));

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
% mpc.branch = [
% 	1	4	0	0.0576	0	250	250	250	0	0	1	-360	360;
% 	4	5	0.017	0.092	0.158	250	250	250	0	0	1	-360	360;
% ];
nbr = size(Branch, 1);
mpc.branch = zeros(nbr, 13);
mpc.branch(:, [1 2]) = Branch(:, [1 2]);
Vbase = vbase * 1e3;
Sbase = mpc.baseMVA * 1e6;              %% in VA
mpc.branch(:, [3 4]) = Branch(:, [3 4]);
mpc.branch(:, [3 4]) = Branch(:, [3 4]) / (Vbase^2 / Sbase); % should be in p.u. according to idx_brch.m
mpc.branch(:, [5:13]) = ...
    repmat([0	250	250	250	0	0	1	-360	360], nbr, 1);
mpc.branch2 = mpc.branch;
mpc.branch2(:, [14 15]) = Branch(:, [3 4]); % extra output: r and x in ohm

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	3	0.11	5	150;
% 	2	2000	0	3	0.085	1.2	600;
% 	2	3000	0	3	0.1225	1	335;
];
% if isempty(Gen_renew)
% else
%     mpc.gencost([2:1+nrow], :) = repmat([2	0	0	3	0.11	5	150], nrow, 1);
% end
end
