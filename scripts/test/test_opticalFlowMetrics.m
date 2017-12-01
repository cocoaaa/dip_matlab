%test computing avg. angle error
addpath('../scripts');
u_est = [ 1 1; 0 0; 0 0; 0 0];
v_est = zeros(4,2);
u_gt = zeros(4,2);
v_gt = zeros(4,2);

flow = cat(3, u_est, v_est);
flowGT = cat(3, u_gt, v_gt);

computeAAE(flow, flowGT)