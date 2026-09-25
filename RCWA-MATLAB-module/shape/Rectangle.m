classdef Rectangle < PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: rec = Rectangle([1,1],[3,3],[2:4],'Si',[1,1]);
    properties
        name = 'Rectangle'
        rectxy
        material
        er
        ur
    end
    
    methods
        function Rect = Rectangle(center,rectxy,nlayer,material,varargin)            
            Rect = Rect@PatternShape(center,nlayer);
            if numel(rectxy) == 2
                Rect.rectxy = rectxy;
            else
                error('Check the rectxy input')
            end
            if nargin == 4
                Rect.er = material.er;
                Rect.ur = material.ur;
                Rect.material = material.MaterialName;
            elseif nargin == 5
                Rect.er = varargin{1}(:,1);
                Rect.ur = varargin{1}(:,2);
                Rect.material = material;
            else 
                error('There is a problem with the number of inputs');
            end                         

        end
        
        
        function BuildPattern(Rect,Dev,varargin)
            % Purpose: make rectangle pattern on the device
            % Input: object cylinder device and wavelength 
             
            x0 = Rect.center(1);
            y0 = Rect.center(2);
            rectx = Rect.rectxy(1);
            recty = Rect.rectxy(2);
            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);
%             if x0-rectx/2 < 0 || y0-recty/2 < 0 || x0+rectx/2 > Lx || y0+recty/2 > Ly
            if rectx > Lx || recty > Ly
                error('The rectangle is too large!')
            end
            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
%             ER = Dev.ER;
%             UR = Dev.UR;            
            dx = Lx/Nx;
            dy = Ly/Ny;
            if isinf(rectx)
                nxrange=1:Nx;
            else
                nx = rectx/(2*dx);
                nx0 = x0/dx;
                nx1 = mod(ceil(nx0-nx),Nx)+1;
                nx2 = mod(ceil(nx0+nx)-1,Nx)+1;
                if nx2<nx1
                    nxrange=[1:nx2,nx1:Nx];
                else
                    nxrange=nx1:nx2;
                end
            end
            if isinf(recty)
                nyrange=1:Nyx;
            else
                ny = recty/(2*dy);
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
                Dev.ER(nxrange,nyrange,Rect.nlayer,:) =  Rect.er;
                Dev.UR(nxrange,nyrange,Rect.nlayer,:) =  Rect.ur;
            elseif nargin == 3
                Dev.ER(nxrange,nyrange,Rect.nlayer,:) = ones(length(nxrange),length(nyrange),numel(Rect.nlayer)).*shiftdim(Rect.er(varargin{1},2),-3);
                Dev.UR(nxrange,nyrange,Rect.nlayer,:) = ones(length(nxrange),length(nyrange),numel(Rect.nlayer)).*shiftdim(Rect.ur(varargin{1},2),-3);
            else
                error('Check input number')
            end
                
        end
      
    end
    
end