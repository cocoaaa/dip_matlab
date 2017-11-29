%% Iterative: using update method in HS paper
close all;
maxIter = 1000;
tolerance = 1e-3;
laplacian_filter = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12 ];
u_curr = zeros(m,n); % u0
v_curr = zeros(m,n); % v0
u_curr_avg = zeros(m,n);
v_curr_avg = zeros(m,n);

diff_u = Inf(m,n);
diff_v = Inf(m,n);
iter = 1;
fRatio = figure;
fShowU = figure;
fShowV = figure;
fHistU = figure;
fHistV = figure;
% while ( any(diff_u(:) > tolerance) || any(diff_v(:) > tolerance)) % too
% strict

while ( mode(mode(diff_u)) > tolerance || mode(mode((diff_v)) > tolerance) ) 
    %using mode instead of mean because diff_u has a humungous range (with sparse big
    %values) 

    if (iter > maxIter)
        break;
    end
    
    ratio = (1./(lambda + Ix.^2.*Iy.^2)).*(Ix.*u_curr_avg + Iy.*v_curr_avg + It);
    set(0, 'CurrentFigure', fRatio);
    imshow(ratio); title("ratio");

    fprintf("max val of ratio: %d\n", max(max(ratio)));
    fprintf("min val of ratio: %d\n", min(min(ratio)));
    fprintf("avg val of ratio: %d\n", mean(mean(ratio)));

    u_next = u_curr_avg - (Ix.*ratio);
    v_next = v_curr_avg - (Iy.*ratio);
    
    diff_u = abs(u_next - u_curr); 
    diff_v = abs(v_next - v_curr);
    
    % update for the next iteration
    u_curr = u_next;
    v_curr = v_next;
    u_curr_avg = conv2(u_curr, laplacian_filter, 'same') ;
    v_curr_avg = conv2(v_curr, laplacian_filter, 'same');
    iter = iter + 1;
    
    % debug
    fprintf("range of u,v: %d, %d\n", range(range(u_curr)), range(range(v_curr)));

    set(0, 'CurrentFigure', fShowU);
    imshow(u_curr);  title("u");
    set(0, 'CurrentFigure', fHistU);
    hist(u_curr); title("hist U");

    set(0, 'CurrentFigure', fShowV);
    imshow(v_curr); title("v");
    set(0, 'CurrentFigure', fHistV);
    hist(v_curr); title("hist V");
    
end

fprintf("---Iterative method ended after %d\n", iter);
figure;
imshowpair(u_curr, v_curr, 'montage'); title('u and v iterative soln');


