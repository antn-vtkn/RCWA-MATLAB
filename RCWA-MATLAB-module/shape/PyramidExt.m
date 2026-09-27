classdef PyramidExt < NamedObject & PatternShape
    % This class is the subclass of PatternShape, it is used to further
    % define the shape of the pattern in three demension
    % Input example:  Pyramid = Pyramid('Rectangle',[0.5,0.5],[0.4,0.4],[1:15],Al,'User Description');
    properties
        Base PatternShape
        Top PatternShape
        Slices PatternShape
        sizeUpper%=nan
    end
    
    methods
        
        function Pyramid = PyramidExt(FaceShape,center,sizexy,nlayer,material,varargin)
            narginchk(5,6);
            
            if ~ismember(FaceShape,PatternShape.EligibleShapes2D)
                error(['Can''t create "' FaceShape '" PatternShape as pyramid''s bases'])
            end
            
            if iscell(sizexy)
                if numel(sizexy)==2
                    size2=sizexy{2};
                elseif numel(sizexy)~=1
                    error('Check the rectxy input')
                end
                size1=sizexy{1};
            else
                size1=sizexy;
            end
            if isscalar(size1)
            elseif numel(size1) == 4 && ~iscell(sizexy)%%circle is not treated properly due to its single size
                size2=size1(3,4);
                size1=size1(1,2);
            elseif numel(size1) ~= 2
                error('Check the rectxy input')
            end
            if ~exist('rectxy2','var')%not specified by input parameters
                size2=[0 0];
                size2(isinf(size1))=inf;
            end
            if iscell(sizexy)
                if isscalar(size2)
                    if size2<0 && ~ismember(FaceShape,PatternShape.CursedShapes2D) %triangle needs separate treatment
                        size2=abs(size2)*size1;
                        size2(isnan(size2))=0;%inf
                    end
                elseif numel(size2) ~= 2
                    error('Check the rectxy{2} input')
                else
                    size2=size2(:);
                    size1=size1(:); %make them the same shape
                end
            end
            Pyramid = Pyramid@PatternShape(center,size1,nlayer,material);
            Pyramid = Pyramid@NamedObject(varargin{:});
            PrefixName(Pyramid,'PyramidExt');
            Pyramid.sizeUpper=size2;
            
%             NullMat=Material('NULL',[nan,nan]);
            FaceShape=str2func(FaceShape);
            Pyramid.Base = feval(FaceShape,center,size1,nlayer(1),material);
            Pyramid.Top = feval(FaceShape,center,size2,nlayer(end),material);
        end
        
        function BuildPattern(Pyramid,Dev,varargin)
            % Purpose: build the layers witch is not homogeneous in the z
            % direction
            narginchk(2,3);

            FaceShape=class(Pyramid.Base);
            CellDim=Dev.xydimension;
            if ismember(FaceShape,PatternShape.RadialDefinedShapes2D)
                CellDim=CellDim/2;
            end
            size1=Pyramid.Base.size;
            size2=Pyramid.Top.size;
            if ismember(FaceShape,PatternShape.SingleDimShapes2D)
                if isinf(size1), size1=min(CellDim); end
                if isinf(size2), size2=min(CellDim); end
            else
                mask=isinf(size1);
                size1(mask)=CellDim(mask);
                mask=isinf(size2);
                size2(mask)=CellDim(mask);
            end
            disp([size1,size2])
            
            material=Pyramid.material;
            nlayer=Pyramid.nlayer;
            center=Pyramid.center;
%             material=Pyramid.material;

            FaceShape=str2func(FaceShape);
            gap = (size1-size2)/numel(nlayer);
            p = 0.5;
            for ii =  Pyramid.nlayer
                Slice = feval(FaceShape,center,size1-p*gap,ii,material);
                BuildPattern(Slice,Dev,varargin{:});
                p = p+1;
            end
            for ii = 1:numel(Pyramid.Slices)
            end
        end
    end
end
