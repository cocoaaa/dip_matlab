% todo: use large scale solver
%     : multi-dimensional
% assumes width == height, ie square input

function output = denoise(input, lambda)
w = size(input,1);
h = size(input,2);
n = w*h;
nNeighbors = 4;

input_vector = reshape(input', [n,1]);

% Diagonal elements
D = sparse(1:n, 1:n, 1+lambda*nNeighbors.*ones(1,n), n, n);

% Off-diagonal
% Inner pixels
% left(idx) = idx - 1;
% right(idx) = idx + 1;
% top(idx) = idx - w;
% bottom(idx) = idx + w;
nInner = (w-2)*(h-2); 
rs_inner = nan(1, nInner*nNeighbors);
cs_inner = nan(1, nInner*nNeighbors);
vals_inner = 1-lambda.*ones(1, nInner*nNeighbors);
i = 1;
for r = 2:h-1
    for c = 2:w-1
        idx = c + (r-1)*w;
        rs_inner(i:i+nNeighbors-1) = idx.*ones(1, nNeighbors);
        cs_inner(i:i+nNeighbors-1) = [idx-1, idx+1, idx-w, idx+w]; 
        
        i = i+nNeighbors;
    end
end
% disp("rs inner:");
% disp(rs_inner);

% disp("cs_inner:");
% disp(cs_inner);

% Debug viz
A_inner = sparse(rs_inner, cs_inner, vals_inner, n, n);
% spy(A_inner);

% Boundary pixels
nBdEntries = 4*2+ 2*(3*(w-2) + 3*(h-2));%2*(w+h) - 4;
rs_bd = nan(1,nBdEntries);
cs_bd = nan(1, nBdEntries);
vals_bd = -lambda*ones(1, nBdEntries);

%top row
i=1;
r = 1;
for c = 2:w-1
    idx = c + (r-1)*w;
    rs_bd(i:i+2) = idx.*ones(1,3);
    cs_bd(i:i+2) = [idx-1, idx+1, idx+w]; 
        
    i = i+3;
end


%last row
r = h;
for c = 2:w-1
    idx = c + (r-1)*w;
    rs_bd(i:i+2) = idx.*ones(1,3);
    cs_bd(i:i+2) = [idx-1, idx+1, idx-w]; 
        
    i = i+3;
end


%first colm
c = 1;
for r = 2:h-1
    idx = c + (r-1)*w;
    rs_bd(i:i+2) = idx.*ones(1,3);
    cs_bd(i:i+2) = [idx+1, idx-w, idx+w]; 
        
    i = i+3;
end

%last colm
c = w;
for r = 2:h-1
    idx = c + (r-1)*w;
    rs_bd(i:i+2) = idx.*ones(1,3);
    cs_bd(i:i+2) = [idx-1, idx-w, idx+w]; 
        
    i = i+3;
end

%four corners
% 1. r=1; c=1; idx = c + (r-1)*w;
idx = 1;
% bottom = idx + w;
rs_bd(i:i+1) = ones(1,2);
cs_bd(i:i+1) = [2,  idx+w]; 
i = i+2;

% 2. r=1; c=w; 
idx = w;
rs_bd(i:i+1) = idx.*ones(1,2);
cs_bd(i:i+1) = [idx-1, idx+w];
i = i+2;

% 3. r=h; c=1;
idx = 1+(h-1)*w;
rs_bd(i:i+1) = idx.*ones(1,2);
cs_bd(i:i+1) = [idx+1, idx-w];
i = i+2;

% 4. r=h; c=w;
idx = w + (h-1)*w;
rs_bd(i:i+1) = idx.*ones(1,2);
cs_bd(i:i+1) = [idx-1, idx-w];
i = i+2;

A_bd = sparse(rs_bd, cs_bd, vals_bd, n, n);
% spy(A_bd);

A = A_inner + A_bd;
% spy(A);

S = D + A;

output = (reshape(S\input_vector, [w,h]))';
end