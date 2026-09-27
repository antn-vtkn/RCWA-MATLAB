classdef Rectangle < NamedObject & PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: rec = Rectangle([1,1],[3,3],[2:4],'Si',[1,1]);
    properties
    end
    
    methods
        function Rect = Rectangle(center,rectxy,nlayer,material,varargin)            
            narginchk(4,5);
            if isscalar(rectxy)
                rectxy = [rectxy rectxy];
            elseif numel(rectxy) ~= 2
                error('Check the rectxy input')
            end
            Rect = Rect@PatternShape(center,rectxy,nlayer,material);
            Rect = Rect@NamedObject(varargin{:});
            PrefixName(Rect,'Rectangle');
        end
        
        
        function BuildPattern(Rect,Dev,waveindices)
            % Purpose: make rectangle pattern on the device
            % Input: object cylinder device and wavelength 
            narginchk(2,3);
             
            x0 = Rect.center(1);
            y0 = Rect.center(2);
            rectx = Rect.size(1);
            recty = Rect.size(2);
            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);
            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
%             if x0-rectx/2 < 0 || y0-recty/2 < 0 || x0+rectx/2 > Lx || y0+recty/2 > Ly
            if isfinite(rectx) && rectx>Lx && Nx>1 || isfinite(recty) && recty>Ly && Ny>1
                error('The rectangle is too large!')
            end
%             ER = Dev.ER;
%             UR = Dev.UR;            
            dx = Lx/Nx;
            dy = Ly/Ny;
            if isinf(rectx)||Nx==1  %this will not comply with the size condition above
                nxrange=1:Nx;
            else
                nx = rectx/(2*dx);
                nx0 = x0/dx;
                if abs(2*nx)<0.5 && Nx>1, return; end
                nx1 = mod(ceil(nx0-nx),Nx)+1;
                nx2 = mod(ceil(nx0+nx)-1,Nx)+1;
                if nx2<nx1
                    nxrange=[1:nx2,nx1:Nx];
                else
                    nxrange=nx1:nx2;
                end
            end
            if isinf(recty)||Ny==1  %this will not comply with the size condition above
                nyrange=1:Ny;
            else
                ny = recty/(2*dy);
                if abs(2*ny)<0.5 && Ny>1, return; end
                ny0 = y0/dy;
                ny1 = mod(ceil(ny0-ny),Ny)+1;
                ny2 = mod(ceil(ny0+ny)-1,Ny)+1;
                if ny2<ny1
                    nyrange=[1:ny2,ny1:Ny];
                else
                    nyrange=ny1:ny2;
                end
            end
            if nargin == 2
                Dev.ER(nxrange,nyrange,Rect.nlayer,:) =  Rect.material.er;
                Dev.UR(nxrange,nyrange,Rect.nlayer,:) =  Rect.material.ur;
            elseif nargin == 3
                Dev.ER(nxrange,nyrange,Rect.nlayer,:) = ones(length(nxrange),length(nyrange),numel(Rect.nlayer)).*shiftdim(Rect.material.er(waveindices,2),-3);
                Dev.UR(nxrange,nyrange,Rect.nlayer,:) = ones(length(nxrange),length(nyrange),numel(Rect.nlayer)).*shiftdim(Rect.material.ur(waveindices,2),-3);
            else
                error('Check input number')
            end
                
        end
      
    end
    
end