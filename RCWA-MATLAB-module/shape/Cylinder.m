classdef Cylinder < PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: Cyl = Cylinder([1,1],3,[2:4],'Si');
    properties
        name = 'Cylinder'
        radius
        material
        er
        ur
    end
    
    methods
        function Cylin = Cylinder(center,radius,nlayer,material)
            Cylin = Cylin@PatternShape(center,nlayer);
            if numel(radius) == 1
                Cylin.radius = radius;
            else
                error('Check the radius input')
            end
            Cylin.er = material.er;
            Cylin.ur = material.ur;
            Cylin.material = material.MaterialName;
                
        end
        
        function BuildPattern(Cylin,Dev,varargin)
            % Purpose: make cylinder pattern on the device
            % Input: object cylinder device and wavelength 
                
            x0 = Cylin.center(1);
            y0 = Cylin.center(2);

            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);
            r = Cylin.radius;
%             if x0-r <= 0 || y0-r <= 0 || x0+r >= Lx || y0+r >= Ly
            if 2*r > min(Lx,Ly)
                error('The radius is too large!')
            end
            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
%             ER = Dev.ER;
%             UR = Dev.UR;
            dx = Lx/Nx;
            dy = Ly/Ny;
            nx = (r/dx);
            nx0 = (x0/dx);
            nx1 = ceil(nx0 - nx)+1;
            nx2 = ceil(nx0 + nx);

            for n = nx1:nx2
                Dx=(n-0.5)*dx-x0;
                Dy=real(sqrt(r^2 - (Dx)^2));
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
                    Dev.ER(nx,nyrange,Cylin.nlayer,:)=Cylin.er;
                    Dev.UR(nx,nyrange,Cylin.nlayer,:)=Cylin.ur;
                elseif nargin == 3
                    Dev.ER(nx,nyrange,Cylin.nlayer,:)=ones(1,length(nyrange),numel(Cylin.nlayer)).*shiftdim(Cylin.er(varargin{1},2),-3);
                    Dev.UR(nx,nyrange,Cylin.nlayer,:)=ones(1,length(nyrange),numel(Cylin.nlayer)).*shiftdim(Cylin.ur(varargin{1},2),-3);
                else
                    error('Check input number')
                end
            end
               
        end
      
    end
    
end