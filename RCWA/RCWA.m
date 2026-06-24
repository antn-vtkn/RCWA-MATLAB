classdef RCWA < handle
    properties(SetAccess=protected)
        ShowProcess             % show the process of the simulation
        BlurCoef = 0          % blur device to accelerate the caculation
        ShrinkCoef = 0         % blur and shrink device to accelerate the caculation
        dispersion = 1          % define dispersion
        RecordField = 0         % reconstructe field inside device 
        RecordDifOrder = 0      % record diffrection order for every wavelength
        referur                 % permeability and permittivity in reflection region
        trnerur                 % permeability and permittivity in transmission region
        R
        T
        Ref_order               % reflection in each order
        Trn_order               % transmission in each order
        source                  % source of the simulation
        device                  % device of the simulation
    end
    
    properties 
        field                   % field of the simualtion
        WhetherBuildLayer=1     % is the layer and material should be build? : If you assign the material by your self, this should be 0
        
    end
    
    properties (Constant,Hidden)
        % Define the units
        micrometers = 1;
        nanometers  = 1 / 1000;
        centimeter = 10000;
        meter = 1000000;
        radians     = 1;
        degrees = pi/180;
        sur_nor = [0; 0; -1];                     % define surface normal
    end
    
    methods
        function ObjRCWA = RCWA(referur,trnerur,ShowProcess)
            % Purpose: Define object RCWA
            % Input: the number of spatial harmonics along x and y (HAS TO BE ODD NUM)
            ObjRCWA.referur = referur;
            ObjRCWA.trnerur = trnerur;
            ObjRCWA.ShowProcess = ShowProcess;
        end
        
        function ObjRCWA = UseBlurEffect(ObjRCWA,BlurCoef)
            % Purpose: open the blur effect to accelerate caculation
            % Input: blur coefficient--How many times the device will be shrinked
            if numel(BlurCoef) == 1
                ObjRCWA.BlurCoef = BlurCoef;
            else
                error('BlurCoef should be a single number')
            end
        end
        
        function ObjRCWA = UseShrinkEffect(ObjRCWA,ShrinkCoef)
            % Purpose: open the blur effect to accelerate caculation
            % Input: blur coefficient--How many times the device will be shrinked
            if numel(ShrinkCoef) == 1
                ObjRCWA.ShrinkCoef = ShrinkCoef;
            else
                error('ShrinkCoef should be a single number')
            end            
            
        end
        
        function ObjRCWA = Dispersion(ObjRCWA,dispersion)
            % Purpose: define the dispersion of materials
            ObjRCWA.dispersion = dispersion;
        end
            
        
        function ObjRCWA = ConstructField(ObjRCWA)
            % Purpose: start record field inside device
            ObjRCWA.RecordField = 1;
%             % initialize field object
%             ObjRCWA.field = 
        end
        
        function ObjRCWA = RecordDiffOrder(ObjRCWA)
           % Purpose: record diffrection order
           ObjRCWA.RecordDifOrder = 1;
        end
        
        function RCWARun(ObjRCWA,source,device,field,Nparallel)
            if ObjRCWA.ShowProcess == 1
                h = waitbar(0,'1','Name','RCWA Caculating...',...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
                setappdata(h,'canceling',0)
            end
            if nargin<5, Nparallel=Inf; end
            
            ObjRCWA.source = source;
            ObjRCWA.device = device;
            PQR=[device.PQR(1:2),2];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if  ObjRCWA.dispersion == 0             % deal with dispersion of the mateiral
                if ObjRCWA.WhetherBuildLayer==1
                    BuildLayer(ObjRCWA.device);
                    BuildPattern(ObjRCWA.device);
                end
                if ObjRCWA.BlurCoef ~= 0         %open the blur effect
                    BlurDevice(ObjRCWA.device,ObjRCWA.BlurCoef)
                end
                if ObjRCWA.ShrinkCoef ~= 0       %open the shrink effect
                    ShrinkDevice(ObjRCWA.device,ObjRCWA.ShrinkCoef)
                end
                ConvDevice(ObjRCWA.device);
            end
            NLAM = source.snum;                  %determine how many simulations
            if ObjRCWA.dispersion == 1
                if ObjRCWA.WhetherBuildLayer==1
                    BuildLayer(ObjRCWA.device,1 : NLAM);
                    BuildPattern(ObjRCWA.device,1 : NLAM);
                end
                if ObjRCWA.BlurCoef ~= 0         %open the blur effect
                    BlurDevice(ObjRCWA.device,ObjRCWA.BlurCoef)
                end
                if ObjRCWA.ShrinkCoef ~= 0       %open the shrink effect
                    ShrinkDevice(ObjRCWA.device,ObjRCWA.ShrinkCoef)
                end
                ConvDevice(ObjRCWA.device);
            end
            if ObjRCWA.RecordField == 1             % initialize Filed object to be prepared to record field
                LayerNum = sum(ObjRCWA.device.ilayer);
                ObjRCWA.field = field;
                ObjRCWA.field.W_V = cell(1,LayerNum);
                ObjRCWA.field.LAM = cell(1,LayerNum);
            end
            
            if ObjRCWA.RecordDifOrder == 1             % initialize matrix to record diffrection for each order
%                 x_k = size(device.PQR);
                Ref_order_ = zeros(PQR(1),PQR(2),NLAM,PQR(3));            % record refection in each order
                Trn_order_ = Ref_order_;            % record transmission in each order
            end
%             if ObjRCWA.RecordField == 1             % initialize Filed object to be prepared to record field
%                 LayerNum = sum(ObjRCWA.device.ilayer);
%                 ObjRCWA.field = Field;
%                 for wavenum = 1: NLAM
%                     ObjRCWA.field(wavenum).wavenumber = wavenum;
%                     ObjRCWA.field(wavenum).W_V = cell(1,LayerNum);
%                     ObjRCWA.field(wavenum).LAM = cell(1,LayerNum);
%                 end
%             end
% %                 ObjRCWA.R = nan(1,NLAM);
% %                 ObjRCWA.T = nan(1,NLAM);
            if isnan(Nparallel)
                Nparallel=numel(gcp('nocreate'));
                if Nparallel, Nparallel=Inf; end
            end
            parfor (nlam = 1 : NLAM, abs(Nparallel))
                % Make patterns in the layer input:[center],radius,[in which ilayer],[er, ur]
                [Ref,Trn] = RCWAer(ObjRCWA,source,ObjRCWA.device,nlam);
                if ObjRCWA.RecordDifOrder == 1
                    Ref_order_(:,:,nlam,:) = reshape(Ref,PQR);            % record refection in each order
                    Trn_order_(:,:,nlam,:) = reshape(Trn,PQR);            % record transmission in each order
                end
                Ref = sum(Ref,1);
                Trn = sum(Trn,1);
                RR(nlam,:) = 100*Ref;
                TT(nlam,:) = 100*Trn;
                % caculate field in device 
                if ObjRCWA.RecordField == 1
                    if ObjRCWA.field.CoordXYZ ~= 0
                        ObjRCWA.field.CaculatePointField
                    elseif ObjRCWA.field.LayerZ ~= 0
                        ObjRCWA.field.CaculateLayerField
                    elseif sum(ObjRCWA.field.GridZ) ~= 0
                        ObjRCWA.field.CaculateGridField;
                    end
                end
            end
            ObjRCWA.R = RR;
            ObjRCWA.T = TT;
            for nlam = 1 : NLAM
                if ObjRCWA.ShowProcess == 1
                    waitbar(nlam/NLAM,h,'I am working, please don''t disturb me ...');
%                     if getappdata(h,'canceling')
%                         delete(h)
%                         break
%                     end
                end
            end
            if ObjRCWA.RecordDifOrder == 1 
                ObjRCWA.Ref_order = Ref_order_;
                ObjRCWA.Trn_order = Trn_order_;
                clear Ref_order_ Trn_order_
            end
            if  ObjRCWA.ShowProcess == 1
                delete(h)
            end
            
        end
        
        
        function PlotRT(ObjRCWA)
            plotRTA(ObjRCWA,[1,1,0]);
        end
        
        function PlotR(ObjRCWA)
            plotRTA(ObjRCWA,[1,0,0]);
        end
           
        function PlotT(ObjRCWA)
            plotRTA(ObjRCWA,[0,1,0]);
        end
        
        function PlotA(ObjRCWA)
            plotRTA(ObjRCWA,[0,0,1]);
        end
        
        function plotRTA(ObjRCWA,doRTA)
            doRTA=~~doRTA;
            if numel(doRTA)<3, doRTA(3)=0; end
            flabels0={'Reflectance', 'Transmittance', 'Absorbance'};
            if ~doRTA(3)
                flabels0{3}='Conservation';
            end
            flabels=flabels0(doRTA);
            if doRTA(1)
                if doRTA(2)
                    fname='Reflection and Transmission';
                    if ~doRTA(3)
                        flabels(3)=flabels0(3);
                    end
                    ftitle='SPECTRAL RESPONSE';
                else
                    fname='Reflection';
                    ftitle=fname;
                end
            else
                if doRTA(2)
                    fname='Transmission';
                    ftitle=fname;
                else
                    if doRTA(3)
                        fname='Absorption';
                        ftitle=fname;
                    else
                        fname='Nothing plot';
                        flabels={'Nothing'};
                        ftitle=fname;
                    end
                end
            end
            % Create figure
            figure1 = figure('Name',fname,'NumberTitle','off');
            
            % Create axes
            axes1 = axes('Parent',figure1,'FontWeight','demi','FontSize',14);
            box(axes1,'on');
            hold(axes1,'all');
            
            Nplot=size(ObjRCWA.R,2);
            for ii=1:Nplot
                if ii==1
                    lnspc='-';
                else
                    lnspc='--';
                end
            if doRTA(1), plot(ObjRCWA.source.wavelength/ObjRCWA.nanometers,ObjRCWA.R(:,1),[lnspc 'r'],'LineWidth',2); hold on; end
            if doRTA(2), plot(ObjRCWA.source.wavelength/ObjRCWA.nanometers,ObjRCWA.T(:,1),[lnspc 'b'],'LineWidth',2); end
            if doRTA(3)||(doRTA(1)&&doRTA(2)), plot(ObjRCWA.source.wavelength/ObjRCWA.nanometers,100-(ObjRCWA.R(:,1)+ObjRCWA.T(:,1)),[lnspc 'k'],'LineWidth',2); end
            end
            hold off;
            
            legend(repmat(flabels,1,Nplot));
            YL=[get(axes1,'Ylim') 0 105];
            YL=[min(YL) max(YL)];
            XL=ObjRCWA.source.wavelength/ObjRCWA.nanometers;
            XL=[min(XL) max(XL)];
            axis([XL YL]);
            xlabel('Wavelength (nm)','FontWeight','demi','FontSize',12);
            ylabel('%   ','Rotation',0,'FontWeight','demi','FontSize',12);
            title(ftitle,'FontWeight','bold','FontSize',14);
        end
        
        function SaveData(ObjRCWA,name)
            filename = strcat(name,'.mat');
            save(filename);
        end
                       
    end
            
end
    
        