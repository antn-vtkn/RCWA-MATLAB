classdef Ellipse < PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: Ellip = Ellipse([0.5,0.5],[0.2,0.3],[2:4],'Si',[1,1]);
    % from left to right is center of the pattern, radius y and radius y, in which
    % layer the pattern will be,the name of the material
    properties
        name = 'Ellipse'
        radius
        material
        er
        ur
    end
    
    methods
        function Ellip = Ellipse(center,radius,nlayer,material)
            Ellip = Ellip@PatternShape(center,nlayer);
            if numel(radius) == 2
                Ellip.radius = radius;
            else
                error('Check the radius input')
            end
            Ellip.er = material.er;
            Ellip.ur = material.ur;
            Ellip.material = material.MaterialName;
                
        end
        
        function BuildPattern(Ellip,Dev,varargin)
            % Purpose: make cylinder pattern on the device
            % Input: object cylinder device and wavelength 
                
            x0 = Ellip.center(1);
            y0 = Ellip.center(2);

            r1 = Ellip.radius(1,1);
            r2 = Ellip.radius(1,2);
            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);            
%             if x0-r1 <= 0 || Lx-x0-r1 <= 0 || y0-r2 <= 0 || Ly-y0-r2 <=0
            if 2*r1>Lx || 2*r2>Ly
                error('The radius is too large!')
            end

%             ER = Dev.ER;
%             UR = Dev.UR;
            dx = Lx/Nx;
            dy = Ly/Ny;
            nx = (r1/dx);
            % ny = round(r2/dy);
            nx0 = (x0*Nx/Lx);
            nx1 = ceil(nx0 - nx)+1;
            nx2 = ceil(nx0 + nx);

            for n = nx1:nx2
                Dy=((n-0.5)*dx-x0)/r1;
                Dy=real(sqrt(1-Dy^2))*r2;
                if abs(Dy/dy)<0.5, continue; end
                ny1 = (y0-Dy)/dy;
                ny2 = (y0+Dy)/dy;
                ny1i = ceil(ny1)+1;
                ny2i = ceil(ny2);
                if (ny2i-ny1i)*(ny2-ny1)<0, continue; end
                ny1i = mod(ny1i-1,Ny)+1;
                ny2i = mod(ny2i-1,Ny)+1;
                if ny2i<ny1i
                    nyrange=[1:ny2i,ny1i:Ny];
                else
                    nyrange=ny1i:ny2i;
                end
                nx=mod(n-1,Nx)+1;
                if nargin == 2
                    Dev.ER(nx,nyrange,Ellip.nlayer,:)=Ellip.er;
                    Dev.UR(nx,nyrange,Ellip.nlayer,:)=Ellip.ur;
                elseif nargin == 3
                    Dev.ER(nx,nyrange,Ellip.nlayer,:)=ones(1,length(nyrange),numel(Ellip.nlayer)).*shiftdim(Ellip.er(varargin{1},2),-3);
                    Dev.UR(nx,nyrange,Ellip.nlayer,:)=ones(1,length(nyrange),numel(Ellip.nlayer)).*shiftdim(Ellip.ur(varargin{1},2),-3);
                else
                    error('Check input number')
                end
            end
               
        end
      
    end
    
end