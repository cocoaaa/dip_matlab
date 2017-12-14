function dPhi_smooth = computeDPhiSmooth(u,v,epsilon)
[ux, uy] = gradient(u);
[vx, vy] = gradient(v);
arg = ux.^2 + uy.^2 + vx.^2 + vy.^2;
dPhi_smooth = 1./(2*sqrt(arg+ epsilon^2));
end
