function [y]=initialRun(s)
addpath("../AMIGO2_R2019a/Kernel/OPT_solvers/eSS/")

%{

----------------------------
The VFA models have not been made so it might be worth looking to make the
VFA models actually and ensure they are added to the documents as well.

----------------------------
%}

opts.maxeval=1000000; %Maximum number of function evaluations
problem.f="fitnessFunction";

ffbyIt=[];


save('ffbyIt.mat','ffbyIt')

uniqueIds=[47, 48, 50, 51];
fitnessFunctionScores=[];

numberOfPointsToAverage=20;

problem.x_0=[-0.504257791202465, -0.009009596393554, -0.015015810556168,...
    -0.125684674696244, -0.002905338716127, -0.198899297082671 ];



load initialStaticCoefs.mat
load staticCoefs.mat

if isfile('iteration.mat')==1
   delete('iteration.mat')
   iteration=0;
   save('iteration.mat','iteration');
end

switch (s)
    case 'W'
        
        load startingModels/whiteStartingModel.mat
        model.light='White';
        miuExp=0.0640686456779267;
        multCoef=0.789677419;
        
    case 'R'
        
        load startingModels/redStartingModel.mat
        model.light='Red';
        miuExp=0.104157835723662;
        multCoef=1.234285714;
    
    case 'B'
        
        load startingModels/blueStartingModel.mat
        model.light='Blue';
        miuExp=0.0560800411699732;
        multCoef=0.708571429;
        
end

if strcmp(model.light,'White')
    
   problem.x_L=[-0.130789516522872, -0.0379289597916327, -0.01275197786098,...
        -0.228881653915025, -0.00539506755656845, -0.588552824352922];

    problem.x_U=[-0.0292104834771284, -0.00847104020836725, -0.00284802213902002,...
         -0.0511183460849748, -0.00120493244343155, -0.131447175647078];
    
elseif strcmp(model.light,'Red')
    
    problem.x_L=[-0.3697004568, -0.0321610887, -0.0083950696,...
        -0.350724194, -0.0067677627, -0.5046639705];
    
    problem.x_U=[-0.211401103, -0.018390266, -0.004800446,...
        -0.200550149, -0.003869924, -0.28857557];

elseif strcmp(model.light,'Blue')
    
    problem.x_L=[-0.1910915776, -0.0665521204, -0.023270307,...
        -0.3238500636, -0.0103114554, -0.7249244759];
    
    problem.x_U=[-0.094119732, -0.032779403, -0.011461494,...
        -0.15950824, -0.005078777, -0.357052354];
end


for i=1:length(staticCoefs)
   staticCoefs(1,i)=initialStaticCoefs(1,i)*multCoef;
end

for i=1:length(problem.x_0)
   problem.x_0(1,i)=problem.x_0(1,i)*multCoef;
end

changeCobraSolver('gurobi')
solution=optimizeCbModel(model);
sprintf('The Primaty growth rate is %d',solution.f)

an=animatedline(0,0,0);

an2=animatedline('Marker','o');

an3=animatedline('Marker','x');

Results=ess_kernel(problem,opts,model,miuExp,uniqueIds,an,an2,fitnessFunctionScores, numberOfPointsToAverage,an3);


fileName=datestr(datetime);
fileName=erase(erase(erase(filename,' '),':'),'-');

save(strcat('ResultsFile/',filename,'.mat'),'Results');

%optimizedGroups=GeneticAlgo(totalVariableNumber,s,model);

% if strcmp(s,'W')
%     newModel=GroupToFBACoef(optimizedGroups,'ff',model,'W');
%     finalCoefs=GroupToFBACoef(optimizedGroups,'end',[],'W');
%     cd('GeneticAlgorithFinalModel/White_Light')
% elseif strcmp(s,'R')
%     newModel=GroupToFBACoef(optimizedGroups,'ff',model,'R');
%     finalCoefs=GroupToFBACoef(optimizedGroups,'end',[],'R');
%     cd('GeneticAlgorithFinalModel/Red_Light')
% elseif strcmp(s,'B')
%     newModel=GroupToFBACoef(optimizedGroups,'ff',model,'B');
%     finalCoefs=GroupToFBACoef(optimizedGroups,'end',[],'B');
%     cd('GeneticAlgorithFinalModel/Blue_Light')
% end
% 
% save ('optimizedGroups.mat','optimizedGroups')
% save ('optimizedModel.mat','newModel')
% save('finalCoefs.mat','finalCoefs')
% 
% MM=runMinMax_max(newModel);
% MM=fixMinMax(MM);
% 
% newModel.lb = MM(:,1);
% newModel.ub = MM(:,2);
% 
% save ('optimisedModelpostFVA.mat','newModel')
% save ('MM.mat','MM')
% finalSolution=optimizeCbModel(newModel);
% 
% if finalSolution.f~=0
%     sprintf('Model with applied FVA does solve with miu %d',finalSolution.f)
% else
%     sprintf('Model with applied FVA does not solve with a resulted miu of %d',finalSolution.f)
% end
% 
% disp(optimizedGroups)
% % fprintf("Number of generations was %d\n",y.Generations)
% % fprintf("The number of function evaluations was : %d\n", y.funccount);
% % fprintf('The best function value found was : %g\n',y); WinScp 
% 

end