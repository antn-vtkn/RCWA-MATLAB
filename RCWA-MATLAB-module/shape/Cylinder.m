classdef Cylinder < NamedObject & PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: Cyl = Cylinder([1,1],3,[2:4],'Si');
    properties
    end
    
    methods
        function Cylin = Cylinder(center,radius,nlayer,material,varargin)
            narginchk(4,5);
            if ~isscalar(radius)
                error('Check the radius input')
            end
            Cylin = Cylin@PatternShape(center,radius,nlayer,material);
            Cylin = Cylin@NamedObject(varargin{:});
            PrefixName(Cylin,'Cylinder');
        end
        
        function BuildPattern(Cylin,Dev,waveindices)
            % Purpose: make cylinder pattern on the device
            % Input: object cylinder device and wavelength 
            narginchk(2,3);
                
            x0 = Cylin.center(1);
            y0 = Cylin.center(2);

            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);
            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
            r = Cylin.size(1);
%             if x0-r <= 0 || y0-r <= 0 || x0+r >= Lx || y0+r >= Ly
            if 2*r>Lx && Nx>1 || 2*r>Ly && Ny>1
                error('The radius is too large!')
            end
%             ER = Dev.ER;
%             UR = Dev.UR;
            dx = Lx/Nx;
            dy = Ly/Ny;
            nx = (r/dx);
            if abs(2*nx)<0.5 && Nx>1, return; end
            nx0 = (x0/dx);
            nx1 = ceil(nx0 - nx)+1;
            nx2 = ceil(nx0 + nx);

            for n = nx1:nx2
                Dx=(n-0.5)*dx-x0;
                Dy=real(sqrt(r^2 - (Dx)^2));
                if abs(2*Dy/dy)<0.5 && Ny>1, continue; end
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
                    Dev.ER(nx,nyrange,Cylin.nlayer,:)=Cylin.material.er;
                    Dev.UR(nx,nyrange,Cylin.nlayer,:)=Cylin.material.ur;
                elseif nargin == 3
                    Dev.ER(nx,nyrange,Cylin.nlayer,:)=ones(1,length(nyrange),numel(Cylin.nlayer)).*shiftdim(Cylin.material.er(waveindices,2),-3);
                    Dev.UR(nx,nyrange,Cylin.nlayer,:)=ones(1,length(nyrange),numel(Cylin.nlayer)).*shiftdim(Cylin.material.ur(waveindices,2),-3);
                else
                    error('Check input number')
                end
            end
               
        end
      
    end
    
end