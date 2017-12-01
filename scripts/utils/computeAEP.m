function aep = computeAEP(flow, flowGT)
% compute avg. end point error between (u_est, v_est) and (u_gt, v_gt):
% ep = sqrt( (u_est-u_gt)^2 + (v_est-v_gt)^2 )
u_est = flow(:,:,1);
v_est = flow(:,:,2);
u = flowGT(:,:,1);
v = flowGT(:,:,2);

ep = sqrt((u_est-u).^2 + (v_est-v).^2);

% filter out the errors from ugt and vgt that are bigger (in abs) than w
% and h, respectively
isValid = ( abs(u) <= size(flowGT, 1) | abs(v) <= size(flowGT,2) );
nValid = sum(isValid(:));
ep = ep .* isValid;

aep = sum(ep(:))/nValid;

end