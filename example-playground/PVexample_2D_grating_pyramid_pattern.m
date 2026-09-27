% Rigorous Coupled-Wave Analysis
% The program is using object oriented program at MATLAB
% Jia LIU Ph.D student, INSA de Lyon
% Supervisor Regis Orobtchouk, INSA de Lyon
% This RCWA method is modified to modle silicon photovoltaics devices 
%% INITIALIZE MATLAB 
% close all; 
clear all; 
clear classes;
% addpath(genpath('n:\Anton\!khznv\rcwa_packages\MatRCWA\MatRCWA-master'));
% addpath(genpath('..'));
RCWAupdatePATH
% clc;
%%
%% Build new simulation object, source and device
tic
% ShowProcess = 1;    % if you cannot delete it try this: set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'))
% % Build new simulation input: ref index [er,ur], trn index [er,ur],waitbar
% Simul = RCWA([1,1],[1,1],ShowProcess);
% % UseShrinkEffect(Simul,4);
% % Record diffrection order
% % RecordDiffOrder(Simul);
% % Build source input: [wavelength],[theta(angle with axis XZ),phi(angle in the XY plane)], polarization
% S = Source([400:410],[0,0],[1/sqrt(2),1/sqrt(2)]);
% Ag = Material('Ag');
Si = Material('silicon');
cSi = Material('csilicon');
Ag = Material('Ag');
Air = Material('Air',1);
Al = Material('Al');
% % % Si.Selectn(S);
% Build device input: [length,width],[number in x,number in y](should be in proportion),[spatial harmonics]
Nrefine=10;
Nz=6*Nrefine;
Nfft=12*2*Nrefine^01;%1024/16;
Nharm=2+0*5;
D = Device([0.06,0.06],[Nfft,Nfft],[Nharm,Nharm]);
% D.improveConvergenceE=01;
D.optimizeUconst=01;
D.optimizeEconst=01;
% AddLayer(D,Air,0.1,1);
AddLayer(D,Si,0.06,Nz);
% AddPattern(D,'Cylinder',[0.3,0.3],0.2,1,Al);
% AddPattern(D,'Cylinder',[0.3,0.3],0.15,1,Air);
% Dispersion(Simul,0);
% AddPattern(D,'Cylinder',[0.5,0.5],0.15,[1:2],Al);
% AddPattern(D,'Rectangle',[0.5,0.5],[0.1,0.3],[1:4],Si)
% AddPattern(D,'Rectangle',[0.3,0.6],[0.1,0.2],[1:4],Si);
% AddPattern(D,'Triangle',[0.3,0.6],0.15,[1:5],ITO);
% AddPattern(D,'Cylinder',[0.45,0.15],0.09,1,Si);
% % AddPattern(D,'Cylinder',[2*0.03--0.01,2*0.03+-0.01],0.02,1,Air);
% % AddPattern(D,'Ellipse',[2*0.03-0.01,2*0.03+0.01],[0.02 0.02/2],1,Al);
% AddPattern(D,'Cylinder',[0.15,0.15],0.05,1,Si);
% AddPattern(D,'Cylinder',[0.45,0.45],0.05,1,Si);
if 0
% AddPattern(D,'Pyramid',[0.03,0.03],[0.03],[1:Nz],Air);
% AddPattern(D,'Pyramid',[0.03,0.03],[0.03,Inf]/2,[1:Nz],Al);
AddPattern(D,'Pyramid',[0.03,0.03],[0.03],[1:Nz],Air);
AddPattern(D,PyramidExt('Ellipse',[0.03,0.03],[0.03,Inf]/2,[1:Nz],Al));
end
if 01
% AddPattern(D,'Pyramid',[0.03,0.03],{[0.03],Inf},[1:Nz],Air,'1st test object');
% AddPattern(D,Pyramid([0.03,0.03],{[0.03,Inf]/2,[0 0.03]},[1:Nz],Al,'2nd test object'));
shape2='Rectangle';
AddPattern(D,{'PyramidExt',shape2},[0.03,0.03],{[0.03],Inf},[1:Nz],Air,'1st test object');
AddPattern(D,PyramidExt(shape2,[0.03,0.03],{[0.03,Inf]/2,[0 0.03]},[1:Nz],Al,'2nd test object'));
% shape2='Ellipse';
% % % % AddPattern(D,{'PyramidExt',shape2},[0.03,0.03],{[0.03]/2,Inf},[1:Nz],Air,'1st test object');
% AddPattern(D,PyramidExt(shape2,[0.03,0.03],{[0.03,Inf]/2/2,[0 0.03]/2/2/2/2},[1:Nz],Al,'2nd test object'));
end
% AddPattern(D,'Rectangle',[0.3,0.3],[0.1,0.2],1,Ag);
% % AddPattern(D,'Triangle',[0.03*2-0,0.03+0],[0.015*2 0.015],1,Al);
% % AddPattern(D,'Triangle',[0.03-0,0.03+0],[0.015*2 -0.015*2],1,Ag);
% % AddPattern(D,'Triangle',[0.03*2-0,0.03+0],0.015*2,1,Al);
% % AddPattern(D,'Triangle',[0.03-0,0.03+0],-0.015*2,1,Ag);
% % AddPattern(D,'Rectangle',[0.03,0.03],[0.01,0.02],1,Al);
D.BuildLayer(1);
D.BuildPattern(1);
ShowLayer(D,1,1);
ShowLayer(D,ceil(Nz/2),1);
% ShowLayer(D,floor(1+Nz/2),1);
ShowLayer(D,Nz-1,1);
ShowLayer(D,Nz,1);
% % % ShowConvLayer(D,1,1);
% rtyweywtywwtrye
% % % toc
% % % tic
% % % % try
% % % RCWARun(Simul,S,D,[],0/0)
% % % % end
% % % toc
% % % tic
% % % PlotRT(Simul)
% % % ShowLayer(D,1);
% % % ShowConvLayer(D,1);
% % % toc

