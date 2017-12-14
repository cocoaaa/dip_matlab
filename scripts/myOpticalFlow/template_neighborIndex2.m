% input
% (m,n): image size, (y,x): pixel index
% 
% category: 
% 0 - inner pixels
% 1 - firstrow
% 2 - lastrow
% 3 - first column
% 4 - last column
% 5 - one of the four corners
% 
function [directs, diagonals] = getNeighborsNaive(m,n,y,x)
%inner pixel
if (2<=x<=n-1 && 2<=y<=m-1)
  directs = [[x-1, y]; [x, y-1]; [x+1, y]; [x, y+1]];
  diagonals = [[x-1, y-1]; [x+1, y-1]; [x-1, y+1]; [x+1, y+1]];

%first-row
elseif ( 2<=x<=n-1 && y==1 )
  directs = [x-1 y; x y+1; x+1 y];
  diagonals = [x-1 y+1; x+1 y+1];
  
%last-row
elseif ( 2<=x<=n-1 && y==m )
  directs = [x-1 y; x y-1; x+1 y];
  diagonals = [x-1 y-1; x+1 y-1];
  
%first-column
elseif (x==1 &&  2<=y<=m-1)
  directs = [x y-1; x+1 y; x y+1];
  diagonals = [x+1 y-1; x+1 y+1];
  
%last-column
elseif (x==n &&  2<=y<=m-1)
  directs = [x y-1; x-1 y; x y+1];
  diagonals = [x-1 y-1; x-1 y+1];
  
%one of the four columns
elseif (x==1 && y==1)
  directs = [x+1 y; x y+1];
  diagonals = [x+1 y+1];
  
elseif (x==n && y==1)
  directs = [x-1 y; x y+1];
  diagonals = [x-1 y+1];
  
elseif (x==1 && y==m)
  directs = [x y-1; x+1 y];
  diagonals = [x+1 y-1];
  
elseif (x==n && y==m)
  directs = [x y-1; x-1 y];
  diagonals = [x-1 y-1];
else
  disp("This should never be printed out");
end

end