classdef Triangle < NamedObject & PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern
    % Input example: Tri = Triangle([1,1],3,[2:4],'Si',[1,1]);
    % Tri = Triangle([centerx,centery],sidelength,[layers],material,er and ur);
    % centerx and centery the center of the rectangle shape device
    properties
    end
    
    methods
        function Tri = Triangle(center,SideLength,nlayer,material,varargin)
            narginchk(4,5);
            if isscalar(SideLength)
                SideLength(2) = 0.5*sqrt(3)*SideLength;  %negative value for an upside-down triangle
            elseif numel(SideLength)==2
              if any(SideLength<0)
                SideLength(2)=-abs(SideLength(2));  %negative value for an upside-down triangle
              end
            else
                error('Check the radius input')
            end
            SideLength(1)=abs(SideLength(1));
            
            Tri = Tri@PatternShape(center,SideLength,nlayer,material);
            Tri = Tri@NamedObject(varargin{:});
            PrefixName(Tri,'Triangle');
        end
        
        function BuildPattern(Tri,Dev,waveindices)
             % Purpose: make equilateral triangle pattern on the device
             % Input: center--the center of the rectangle,SideLength--side
             % length,nlayer--in which layer will the rectangle
             % be, filler--the material that will fill the hole.
             % Inputformat: Dev =Dev.RectanglePatternDevice([0.2,0.25],0.1,[3:5],[2,1]);                           
            narginchk(2,3);

            Nx = Dev.idimension(1);
            Ny = Dev.idimension(2);
            Lx = Dev.xydimension(1);
            Ly = Dev.xydimension(2);
%             ER = Dev.ER;
%             UR = Dev.UR;
            dx = Lx/Nx;
            dy = Ly/Ny;
            SideLen = Tri.size(1);
            h=Tri.size(2);
            UpsideDown=h<0;
            h=abs(h);
            
            x0 = Tri.center(1);
            y0 = Tri.center(2);
%             if abs((Lx/2-x0))+SideLen/2 > Lx/2 || h*2/3+y0>Ly ...
%                     ... || -h/3+y0<0
            if SideLen>Lx && Nx>1 || h>Ly && Ny>1
                error('The triangle is too large!')
            end            
            nxm = (Lx/2-x0)/dx;
            nym = (Ly/2-y0)/dy;
            ny = h/dy; 
            if abs(ny)<0.5 && Ny>1, return; end
            ny1 = (Ny/2 - (1+~UpsideDown)*ny/3)-nym; 
            ny2 = ny1 + ny;
            ny1i = ceil(ny1)+1; 
            ny2i = ceil(ny2);
            for n = ny1i:ny2i
                if UpsideDown
                    f=ny2-(n-0.5); 
                else
                    f=(n-0.5)-ny1; 
                end
                f = f / (ny2-ny1);
                nx = f*SideLen/dx;
                if abs(nx)<0.5 && Nx>1, continue; end
                nx1=(Nx - nx)/2-nxm;
                nx2=nx1 + nx;
                nx1i=ceil(nx1)+1;
                nx2i=ceil(nx2);
                if (nx2i-nx1i)*(nx2-nx1)<0, continue; end
                nx1i = mod(  nx1i-1,Nx)+1;
                nx2i = mod(  nx2i-1,Nx)+1;
                if nx2i<nx1i
                    nxrange=[1:nx2i,nx1i:Nx];
                else
                    nxrange=nx1i:nx2i;
                end
                ny=mod(n-1,Ny)+1;
                if nargin == 2
                    Dev.ER(nxrange,ny,Tri.nlayer,:) = Tri.material.er;
                    Dev.UR(nxrange,ny,Tri.nlayer,:) = Tri.material.ur;
                elseif nargin == 3
                    Dev.ER(nxrange,ny,Tri.nlayer,:) = ones(length(nxrange),1,numel(Tri.nlayer)).*shiftdim(Tri.material.er(waveindices,2),-3);
                    Dev.UR(nxrange,ny,Tri.nlayer,:) = ones(length(nxrange),1,numel(Tri.nlayer)).*shiftdim(Tri.material.ur(waveindices,2),-3);
                else
                    error('Check input number')
                end
            end
                
        end
      
    end
    
end