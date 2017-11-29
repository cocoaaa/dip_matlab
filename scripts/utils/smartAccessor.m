function intensity = smartAccessor(im, y, x, option)
    % option
    % 'zero'       : zero-padding, 
    % 'nn'         : nearest neighbor
    % 'distWeight' :
    if nargin == 3
        option = 'nn';
    end
    
    [h,w] = size(im);
%     fprintf('option: %s', option);
   
    switch option 
        
        case 'zero'
            if (y < 1 || y > h || x < 1 || x > w)
                intensity = 0;
            else; intensity = im(y,x);
            end
            
        case 'nn'
            if (y<1); y=1; end
            if (y>h); y=h; end
            if (x<1); x=1; end
            if (x>w); x=w; end
            intensity = im(y,x);
            
        case 'distWeight'
            if (y <= 1); dy = 1 - y;
            elseif (y >= h); dy = h - y;
            else; dy = 0;
            end

            if (x <= 1); dx = 1 - x;
            elseif (x >= w); dx = w - x;
            else; dx = 0;
            end

            d = sqrt(dx*dx + dy*dy);
            intensity = im(y + dy, x + dx);

            if (d > 1e-6)
                intensity = im(y+dy, x+dx)/d;
            end     
    end
end
