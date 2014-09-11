function [modelP,siteInfo,datain]=readModelFile(filename);
%READMODELFILE reads data from a standard excel
%spreadsheet and places info into three data
%structures
%
%INPUT: filename- filename of file to read.
%
%OUTPUT: modelP, siteInfo and datain are input
%parameters the model will run from

[data,hdr]=xlsread(filename);

modelP.numIterations=data(1,2);
modelP.vonK=data(2,2);
modelP.numBins=data(3,2);
modelP.resuspCoeff=data(4,2);
modelP.concConvFac=data(5,2);
modelP.sizeConvFac=data(6,2);
modelP.eddyViscShape=data(7,2);

siteInfo.name=hdr(11,2);
siteInfo.description=hdr(12,2);
siteInfo.depositThickness=data(12,2);
siteInfo.depth=data(13,2);
siteInfo.salinity=data(14,2);
siteInfo.waterTemp=data(15,2);
siteInfo.meanGrainSize=data(16,2);
siteInfo.sedDensity=data(17,2);
siteInfo.bedConc=data(18,2);

lenHdr=length(hdr);

datain.phi=data(lenHdr+1:end,1);
datain.weights=data(lenHdr+1:end,2);