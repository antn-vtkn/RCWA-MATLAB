classdef Ellipse < NamedObject & PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: Ellip = Ellipse([0.5,0.5],[0.2,0.3],[2:4],'Si',[1,1]);
    % from left to right is center of the pattern, radius y and radius y, in which
    % layer the pattern will be,the name of the material
    properties
    end
    
    methods
        function Ellip = Ellipse(center,radius,nlayer,material,varargin)
            narginchk(4,5);
            if isscalar(radius)
                radius = [radius,radius];
            elseif numel(radius) ~= 2
                error('Check the radius input')
            end
            Ellip = Ellip@PatternShape(center,radius,nlayer,material);
            Ellip = Ellip@NamedObject(varargin{:});
            PrefixName(Ellip,'Ellipse');                
        end
        
        function BuildPattern(Ellip,Dev,waveindices)
            % Purpose: make cylinder pattern on the device
            % Input: object cylinder device and wavelength 
            narginchk(2,3);
                
            x0 = Ellip.center(1);
            y0 = Ellip.center(2);

            r1 = Ellip.size(1);
            r2 = Ellip.size(2);
            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);            
%             if x0-r1 <= 0 || Lx-x0-r1 <= 0 || y0-r2 <= 0 || Ly-y0-r2 <=0
            if 2*r1>Lx && Nx>1 || 2*r2>Ly && Ny>1
                error('The radius is too large!')
            end

%             ER = Dev.ER;
%             UR = Dev.UR;
            dx = Lx/Nx;
            dy = Ly/Ny;
            nx = (r1/dx);
            if abs(2*nx)<0.5 && Nx>1, return; end
            % ny = round(r2/dy);
            nx0 = (x0*Nx/Lx);
            nx1 = ceil(nx0 - nx)+1;
            nx2 = ceil(nx0 + nx);

            for n = nx1:nx2
                Dy=((n-0.5)*dx-x0)/r1;
                Dy=real(sqrt(1-Dy^2))*r2;
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
                    Dev.ER(nx,nyrange,Ellip.nlayer,:)=Ellip.material.er;
                    Dev.UR(nx,nyrange,Ellip.nlayer,:)=Ellip.material.ur;
                elseif nargin == 3
                    Dev.ER(nx,nyrange,Ellip.nlayer,:)=ones(1,length(nyrange),numel(Ellip.nlayer)).*shiftdim(Ellip.material.er(waveindices,2),-3);
                    Dev.UR(nx,nyrange,Ellip.nlayer,:)=ones(1,length(nyrange),numel(Ellip.nlayer)).*shiftdim(Ellip.material.ur(waveindices,2),-3);
                else
                    error('Check input number')
                end
            end
               
        end
      
    end
    
end