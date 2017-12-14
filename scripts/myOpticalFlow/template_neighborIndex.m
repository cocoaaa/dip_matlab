% template for accessing neighbors
% directs: 4-neighborhood
% diagonals: 8-neighborhood
% m,n = height, width of 2d image


%% MATLAB (1-based, column-prioritized ) 1d to 2d index conversion
% an example of 1d index at 2d domain
% 1 4 7 10  
% 2 5 8 11
% 3 6 9 12

cIdx = floor( (i-1)/m ) + 1;
rIdx = i - (cIdx-1)*m;


%% Neighbord index accesses
[m,n] = size(im);
%inner pixels
for x=2:n-1
  for y=2:m-1
    directs = [[x-1, y]; [x, y-1]; [x+1, y]; [x, y+1]];
    diagonals = [[x-1, y-1]; [x+1, y-1]; [x-1, y+1]; [x+1, y+1]];
  end
end

%first-row
y=1;
for x=2:n-1
  directs = [x-1 y; x y+1; x+1 y];
  diagonals = [x-1 y+1; x+1 y+1];
end

%last-row
y=m;
for x=2:n-1
  directs = [x-1 y; x y-1; x+1 y];
  diagonals = [x-1 y-1; x+1 y-1];
end

%first-colm
x=1;
for y=2:m-1
  directs = [x y-1; x+1 y; x y+1];
  diagonals = [x+1 y-1; x+1 y+1];
end

% last-colm
x=n;
for y=2:m-1
  directs = [x y-1; x-1 y; x y+1];
  diagonals = [x-1 y-1; x-1 y+1];
end

% four corners
x=1;y=1;
directs = [x+1 y; x y+1];
diagonals = [x+1 y+1];

x=n;y=1;
directs = [x-1 y; x y+1];
diagonals = [x-1 y+1];

x=1;y=m;
directs = [x y-1; x+1 y];
diagonals = [x+1 y-1];

x=n;y=m;
directs = [x y-1; x-1 y];
diagonals = [x-1 y-1];
