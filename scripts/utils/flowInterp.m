function [ut, vt, parentX, parentY] = flowInterp(im1, im2, u1, v1, t)
    [h,w] = size(im1);
    ut = nan(h,w);
    vt = nan(h,w);
    parentX = nan(h,w);
    parentY = nan(h,w);
    
    r = 0.5;
    
    for x=1:w
        for y=1:h
            yt = round(y + t*v1(y,x));
            xt = round(x + t*u1(y,x));

            target = splatTargets(xt, yt, r, w, h);
            if (size(target,1) == 0)
                continue;
            end

            if size(target,1) > 1
                fprintf("target index must be at most 1: %d", size(target,1));
            end
            
            xt = target(1,1);
            yt = target(1,2);
            
            % If a location is targeted more than once, we get the value
            % of flow that minimizes the intensity difference btw im1 and
            % im2
            if isnan(parentX(yt,xt))
                ut(yt, xt) = u1(y,x);
                vt(yt, xt) = v1(y,x);
                parentX(yt, xt) = x;
                parentY(yt, xt) = y;
                
            else 
                % choose the one that minimizes the intensity difference
                oldx = parentX(yt,xt); oldy = parentY(yt, xt);
                new_diff = abs(im1(y,x) - im2(round(y+v1(y,x)), round(x+u1(y,x))));
                old_diff = abs(im1(oldy,oldx) - im2(oldy+v1(oldy, oldx), oldx+u1(oldy, oldx)));
                if new_diff > old_diff
                  continue;
                else 
                  ut(yt, xt) = u(y,x);
                  vt(yt, xt) = v(y,x);
                  parentX(yt, xt) = x;
                  parentY(yt, xt) = y; 
                end
            end
            
        end
    end
    
    % not-splatted locations 
    ut(isnan(ut)) = u1(isnan(ut));
    vt(isnan(vt)) = v1(isnan(vt));
    
    % also return parentX and parentY (with nans at not-splatted locations)
    
end
