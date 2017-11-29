%% Gauss Seidel Method
%% Solution of x in Ax=b using Gauss Seidel Method
% * _*Initailize 'A' 'b' & intial guess 'x'*_
%%
function [x] = gauss_seidel(A, b, x0, iters)
    n = length(A);
    x = x0;
    for k = 1:iters
        tic
        sprintf("\niter: %d",k);
        for i = 1:n
            x(i) = (1/A(i, i))*(b(i) - A(i, 1:n)*x + A(i, i)*x(i));
        end
        toc
        
        figure;
        imshowpair(vecToIm(x(1:n/2), 232, 180), vecToIm(x(n/2+1:end), 232, 180));
        title(sprintf("u,v after iter%d", k));
    end
end



% 
% function x = gauss_seidel(A, b, x, maxIter, tol)
%     if ~exist('maxIter', 'var')
%     maxIter = 1000;
%     disp('here');
%     end
%     
%     if ~exist('tol', 'var')
%     tol = 1e-5;
%     end
% 
%     n=size(x,1);
%     normVal=Inf; 
%     itr=0;
%     while itr < maxIter
%         if (normVal<tol) 
%             break; 
%         end
%         
%         if (mod(itr, 10)==0) 
%             disp(itr)
%         end
%         
%         x_old=x;
% 
%         for i=1:n
% 
%             sigma=0;
% 
%             for j=1:i-1
%                     sigma=sigma+A(i,j)*x(j);
%             end
% 
%             for j=i+1:n
%                     sigma=sigma+A(i,j)*x_old(j);
%             end
% 
%             x(i)=(1/A(i,i))*(b(i)-sigma);
%         end
% 
%         itr=itr+1;
%         normVal=norm(x_old-x);
%        
%     end
%     
%     fprintf('Solution of the system is : \n%f\n%f\n%f\n%f in %d iterations',x,itr);
% 
% end