function avgAE = computeAAE(flow, flowGT)
% computes avg. angular error between two normalized flows
% in 3D space: (uest, vest,1) vs ( ugt, vgt, 1)
% Note magnitude of flow at any point is non-zero.
%   So, we don't need to worry about division by zero for a zero-flow.
u_est = flow(:,:,1);
v_est = flow(:,:,2);
u = flowGT(:,:,1);
v = flowGT(:,:,2);

magFlow = sqrt((u_est.^2 + v_est.^2 + 1));
magFlowGT = sqrt(u.^2 + v.^2 + 1);
invMagMult = 1./(magFlow.*magFlowGT);

absAngle = abs( acos( (u_est.*u + v_est.*v).*invMagMult )) ;
avgAE = mean(absAngle(:));

end
