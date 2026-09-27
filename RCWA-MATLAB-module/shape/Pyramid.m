classdef Pyramid < NamedObject & PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern in three demension
    % Input example:  Pyramid = Pyramid([0.5,0.5],[0.4,0.4],[1:15],Al);
    % there are from left to right is center point, the sidelength of x and
    % y, in which layer the pyramid will be, name of the material
    % One thing needs to notice is that the depth of the pyramid is decide
    % in the AddLayer part!!!
    properties
        sizeUpper
    end
    
    methods
        
        function Pyramid = Pyramid(center,rectxy,nlayer,material,varargin)
            narginchk(4,5);
            
            if iscell(rectxy)
                if numel(rectxy)==2
                    rectxy2=rectxy{2};
                elseif numel(rectxy)~=1
                    error('Check the rectxy input')
                end
                rectxy1=rectxy{1};
            else
                rectxy1=rectxy;
            end
            if isscalar(rectxy1)
            elseif numel(rectxy1) == 4 && ~iscell(rectxy)
                rectxy2=rectxy1(3,4);
                rectxy1=rectxy1(1,2);
            elseif numel(rectxy1) ~= 2
                error('Check the rectxy input')
            end
            if ~exist('rectxy2','var')%not specified by input parameters
                rectxy2=[0 0];
                rectxy2(isinf(rectxy1))=inf;
            end
            if iscell(rectxy)
                if isscalar(rectxy2)
                    if rectxy2<0%future triangle needs separate treatment
                        rectxy2=abs(rectxy2)*rectxy1;
                        rectxy2(isnan(rectxy2))=0;%inf
                    end
                elseif numel(rectxy2) ~= 2
                    error('Check the rectxy{2} input')
                else
                    rectxy2=rectxy2(:);
                    rectxy1=rectxy1(:); %make them the same shape
                end
            end
            Pyramid = Pyramid@PatternShape(center,rectxy1,nlayer,material);
            Pyramid = Pyramid@NamedObject(varargin{:});
            PrefixName(Pyramid,'Pyramid');
            Pyramid.sizeUpper=rectxy2;
        end
        
        function BuildPattern(Pyramid,Dev,varargin)
            % Purpose: build the layers witch is not homogeneous in the z
            % direction
            narginchk(2,3);

            layernum = numel(Pyramid.nlayer);
            rectcenter = Pyramid.center;
            rectrectxy = Pyramid.size; 
            rectrectxy2 = Pyramid.sizeUpper;
            
            mask=isinf(rectrectxy);
            if isscalar(mask) && mask
                rectrectxy=Dev.xydimension;
            else
                rectrectxy(mask)=Dev.xydimension(mask);
            end
            
            mask=isinf(rectrectxy2);
            if isscalar(mask) && mask
                rectrectxy2=Dev.xydimension;
            else
                rectrectxy2(mask)=Dev.xydimension(mask);
            end
            
%             rectrectxyRatio=rectrectxy2./rectrectxy;
            gap = (rectrectxy-rectrectxy2)/(layernum-0);
%             rectmaterial = Pyramid.material;

            p = 0.5;
            for i =  Pyramid.nlayer
                Rect = Rectangle(rectcenter,rectrectxy-p*gap,i,Pyramid.material);
                BuildPattern(Rect,Dev,varargin{:});
                p = p+1;
            end
        end
    end
end
