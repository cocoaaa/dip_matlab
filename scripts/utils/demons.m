%% Demon's algorithm

function deformed = demons_2d(M, S, maxIter, precision)
    % M: moving image (source) after anisotropic smoothing
    % S: Fixed image (target) after anisotropic smoothing 
    % Gs : gradient of S. size of height*weight*2. 
    %   Gs[:,:,1] = Gx and Gs[:,:,1] = Gy
    
    % U: displacement field over F. size of height*width*2. 
    %   U(:,:,1) = displacement field in x-direction
    %   U(:,:,2) = displacement field in y-direction
    
    Idiff = (M-S);
    diff = sum(sum(Idiff.*Idiff));
    quiver(Idiff, 
    [height,width] = size(S);
    [Gx, Gy] = imgradientxy(S);
    Gmag = sqrt(Gx.*Gx  + Gy.*Gy);
    figure;
    imshow(Gmag,[]); title("Gmag");
%     [Gmag, Gdir] = imgradient(Gx, Gy);
%     Gmag_zeros = ones(height, width); 
%     Gmag_zeros( abs(Gmag) < 1e-7 ) = 0;
%     figure; imshow(Gmag_zeros); title('zero gradient map for F');
    
    % Initialize displacement field
    U = zeros(height, width, 2);
    
    for i=1:maxIter
        
        for y = 1:height
            for x = 1:width
                if ( abs(Gmag(y,x)) < 1e-7 )
                    continue
                end
                x_src = x + U(y,x,1);
                y_src = y + U(y,x,2);
                m = smartAccessor(M, y_src, x_src); %todo: add option to interpolate
                s = S(y,x);
                U(y,x,1) = -(m-s)*Gx(y,x)/(Gmag(y,x)*Gmag(y,x) + (m-s)*(m-s));
                U(y,x,2) = -(m-s)*Gy(y,x)/(Gmag(y,x)*Gmag(y,x) + (m-s)*(m-s));
                
            end        
        end
        figure;
        [X,Y] = meshgrid(1:width, height:1);
        quiver(X,Y, U(:,:,1), U(:,:,2));
        title( sprintf('%d-iter: U map over fixed',i) );
        
        figure;
        imshow( U(:,:,1).*U(:,:,1) + U(:,:,2).*U(:,:,2) ); title('displacement');
    end
     
%     deformed = zeros(height, width);
%     deformed(y,x) = smartAccessor( S, y + U(y,x,2), x + U(y,x,1) );
 
    deformed = zeros(height*2, width*2);
    deformed_better = zeros(height, width);
    for y=1:height
        for x = 1:width
            deformed(y,x) = S(y + U(y,x,2), x + U(y,x,1));
            defomred_better(y,x) = smartAccessor(S, y + U(y,x,2), x + U(y,x,1));
        end
    end
    
    figure;
    imshowpair(M,S, 'montage'); title('moving vs fixed');
    
    figure;
    imshowpair(M,S); title('moving vs. fixed');
    
    
    figure;
    imshow(deformed,[]); title('deformed');
    
    
%     imshowpair(deformed_better);
    title( 'deformed extended size and deforemd fixed size' );
    
end

