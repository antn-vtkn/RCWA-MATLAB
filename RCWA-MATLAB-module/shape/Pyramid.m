classdef Pyramid < PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern in three demension
    % Input example:  Pyramid = Pyramid([0.5,0.5],[0.4,0.4],[1:15],Al);
    % there are from left to right is center point, the sidelength of x and
    % y, in which layer the pyramid will be, name of the material
    % One thing needs to notice is that the depth of the pyramid is decide
    % in the AddLayer part!!!
    properties
        name = 'Pyramid'
        rectxy
        material
        er
        ur
    end
    
    methods
        
        function Pyramid = Pyramid(center,rectxy,nlayer,material)
            Pyramid = Pyramid@PatternShape(center,nlayer);
            Pyramid.rectxy = rectxy;
            Pyramid.er = material.er;
            Pyramid.ur = material.ur;
            Pyramid.material = material.MaterialName;            
        end
        
        function BuildPattern(Pyramid,Dev,varargin)
            % Purpose: build the layers witch is not homogeneous in the z
            % direction
            layernum = numel(Pyramid.nlayer);
            rectcenter = Pyramid.center;
            rectrectxy = Pyramid.rectxy; 
            rectrectxyRatio=0;
            gapRatio = (1-rectrectxyRatio)/(layernum-1);
            rectmaterial = Pyramid.material;

            if nargin == 2
                recter = Pyramid.er;
                rectur = Pyramid.ur;
            elseif nargin == 3
                recter = Pyramid.er(varargin{1},2);
                rectur = Pyramid.ur(varargin{1},2);
            else
                error('Input problem')
            end
            p = 0.5;
            for i =  Pyramid.nlayer
                Rect = Rectangle(rectcenter,rectrectxy.*(1-p*gapRatio),i,rectmaterial,[recter,rectur]);
                BuildPattern(Rect,Dev);
                p = p+1;
            end
        end
    end
end
