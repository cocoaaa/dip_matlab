addpath('../utils');
% Test smartAccessor

A = [1 2 3; 4 5 6]

smartAccessor(A, 1,1)
smartAccessor(A, 0,1)
smartAccessor(A, 1,0)
smartAccessor(A, 5,1)
smartAccessor(A, 1,5)
smartAccessor(A, 2,3)
smartAccessor(A, 1,2)

