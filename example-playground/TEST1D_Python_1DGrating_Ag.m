% ä¸ºäº†ä¿è¯è®¡ç®—ç»“æžœçš„å‡†ç¡®æ€§ï¼Œå’Œä¸€äº›æ–‡çŒ®çš„ç»“æžœè¿›è¡Œå¯¹æ¯”
% è¿™é‡Œå’ŒPythonçš„ç»“æžœè¿›è¡Œå¯¹æ¯”ï¼šæ¥è‡ªgithubä»“åº“ï¼Œhttps://github.com/zhaonat/Rigorous-Coupled-Wave-Analysis
% ç”¨æ¥å¯¹æ¯”çš„æºPythonä»£ç åœ°å€ï¼šhttps://github.com/zhaonat/Rigorous-Coupled-Wave-Analysis/blob/master/RCWA_1D_examples/1D_Grating_Gaylord_TE.py

addpath(genpath('.'));

% eps_layer=3.48^2;
width=0.3*0.7*1.5;
period=0.7*1.5;
d_groove=0.26;
d_coating=0.2;
% lambda=linspace(500,2300,401);
epssup=1;epssdn=1;
num_xy=1021;
numz=1;
num_har=2*2*50+1;
% num_xy=2*2*2*num_har-1;
mid_layer=Material('Ag');
substrate=Material('silicon');%the lattice is different; unable to process properly as of now
lambda=real(mid_layer.er(:,1))*1e3;%mkm to nm
%% 
Air = Material('Vacuum',[1,1]);
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(lambda,[005,0],[01,0*1]);
Dev = Device([period,period*8],[num_xy,1],[num_har,1]);
% % Dev.improveConvergenceE=01;
% Dev.optimizeUconst=01;
% Dev.optimizeEconst=01;
AddLayer(Dev,Air,d_groove,numz);
AddPattern(Dev,'Rectangle',[period/2,period*8/2],[width width],1,mid_layer);
AddLayer(Dev,mid_layer,d_coating,1);
AddLayer(Dev,substrate,1*d_groove,1);%áåç íåãî ïî÷åìó-òî âîçíèêàåò íåáîëüøîé ïèê ïðîïóñêàíèÿ íà îäíîé èç ÷àñòîò
% Run Simulations
RecordDiffOrder(Simul);
RCWARun(Simul,S,Dev)
% PlotRT(Simul)
% 
% saveas(gcf,'./figures/TEST1D_Python_1DGrating_Ag.png');

%%
threshold=1e-3;  %out of 1; not of 100
xplot=Simul.source.wavelength/Simul.nanometers;
% yplot1=any(Simul.Ref_order~=0,3);
yplot1=any(any(Simul.Ref_order>threshold,3),4);
% yplot2=any(Simul.Trn_order~=0,3);
yplot2=any(any(Simul.Trn_order>threshold,3),4);
for ii=1:size(Simul.Ref_order,4)
figure;
yplot=squeeze(Simul.Ref_order(yplot1,:,:,ii))';
plot(xplot,yplot);
legend;
hold on; 
% figure;
yplot=squeeze(Simul.Trn_order(yplot2,:,:,ii))';
if numel(yplot), myplot(xplot,yplot,'--'); end
legend;
end
