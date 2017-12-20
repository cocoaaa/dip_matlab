function dPhi_smooth = computeDPhiSmooth(u,v,du, dv, epsilon)
[ux, uy] = gradient(u+du);
[vx, vy] = gradient(v+dv);
arg = ux.^2 + uy.^2 + vx.^2 + vy.^2;
dPhi_smooth = 1./(2*sqrt(arg+ epsilon^2));
end
