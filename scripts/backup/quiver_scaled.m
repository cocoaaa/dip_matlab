function h=quiver_scaled(x,y,u,v)
%QUIVER_SCALED Scaled quiver plot.
%   quiver_scaled(x,y,u,v) calls the Matlab quiver plot function in such a
%   way as to get nice looking arrow heads in the case of x and y dimensions
%   of different orders of magnitude
%
%   See also QUIVER

%   Ian Bruce (ibruce@ieee.org)
%   Written November 2004; Updated November 2005 to work with Matlab v7.x

xrange = max(max(x))-min(min(x)); % Compute the range of x values
yrange = max(max(y))-min(min(y)); % Compute the range of y values

scale_factor = xrange/yrange;  %  Compute a scale factor based of the ratio
                               %  of the x-range to the y-range

if (strncmp(version('-release'),'20',2))
    h=quiver('v6',x,y*scale_factor,u,v*scale_factor); %  Call the quiver function with scaled data    
elseif (eval(version('-release'))>13)
    h=quiver('v6',x,y*scale_factor,u,v*scale_factor); %  Call the quiver function with scaled data
else
    h=quiver(x,y*scale_factor,u,v*scale_factor); %  Call the quiver function with scaled data
end    
ydata = get(h(1),'ydata');  %  Get the handle for the y data points of the arrow lines
set(h(1),'ydata',ydata/scale_factor);  %  Re-scale the y data points of the arrow lines
ydata = get(h(2),'ydata');  %  Get the handle for the y data points of the arrow heads
set(h(2),'ydata',ydata/scale_factor);   %  Re-scale the y data points of the arrow heads
