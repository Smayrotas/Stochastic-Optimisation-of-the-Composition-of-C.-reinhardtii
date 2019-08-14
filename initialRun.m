function [y]=initialRun(s,type,path)
addpath("../AMIGO2_R2019a/Kernel/OPT_solvers/eSS/")
cd ~/Desktop/UCL/Research_Project_Publication/ScatterSearchOptimisation/

%{

-----------------------

--> Save the finalModel after all the iterations

--> Save the graphs as well

-----------------------

%}

opts.maxeval=1000; %Maximum number of function evaluations
opts.maxtime=1000; %Maximum CPU time in seconds
%opts.plot=2;
problem.f="fitnessFunction";
fileName=string();


bestSolutions=[];

fitnessFunctionScores=[];

numberOfPointsToAverage=20;
if strcmp(type,'auto')
    load initialStaticCoefs.mat
problem.x_0=[-0.504257791202465, -0.009009596393554, -0.015015810556168,...
    -0.125684674696244, -0.002905338716127, -0.198899297082671 ];

elseif strcmp(type,'mixo')
    load initialStaticCoefsMixo.mat
problem.x_0=[-0.50507593272838500000, -0.00700746386165342000 ,...
        -0.01301370248201190000,-0.12568467469624400000 ,-0.00002278606909204460...
        ,-0.22402395784666000000 ];

end

if isfile('iteration.mat')==1
   delete('iteration.mat')
   iteration=0;
   save('iteration.mat','iteration');
end

if isfile('ess_report.mat')==1
   delete('ess_report.mat');
end


switch (s)
    case 'W'      
        s='white';      
    case 'R'
        s='red';
           
    case 'B'
        s='blue';
     
end

%b=join([pwd]);
%path=fileFinder(s,b);
%path=path(1,1);
%cd ~
load(path)
%pathInd=regexp(path,'\w*starting');
%path=char(path);
%path=join(['~/',path(1:pathInd-1)]);
%cd('/Users/SteliosMavrotas/Desktop/UCL/Research_Project_Publication/ScatterSearchOptimisation')

%disp(model.id)
if strcmp(type,'auto')
    %ind=find([model.rxns{:,1}]=='Biomass_Chlamy_auto');
    ind=53;
elseif strcmp(type,'mixo')
    %ind=find([model.rxns{:,1}]=='Biomass_Chlamy_mixo');
    ind=54;
end
    
miuExp=(model.lb(ind)+model.ub(ind))/2;

if and(strcmp(s,'white'),strcmp(type,'auto')) 
    
   problem.x_L=[-0.1302295295, -0.0377665636, -0.0126973791,...
       -0.2279016767,-0.0053719681,-0.5860328830];
   
    problem.x_U=[-0.0297704705,-0.0086334364,-0.0029026209,...
        -0.0520983233,-0.0012280319,-0.1339671170];
    
     problem.light='W';
     
elseif and(strcmp(s,'red'),strcmp(type,'auto'))
    
    problem.x_L=[-0.3697004568,-0.0321610887,-0.0083950696,...
        -0.3507241940,-0.0067677627,-0.5046639705];
    
    problem.x_U=[-0.2114011034,-0.0183902657,-0.0048004457,...
        -0.2005501487,-0.0038699236,-0.2885755705];
    
    problem.light='R';
    
elseif and(strcmp(s,'blue'),strcmp(type,'auto'))
    
    problem.x_L=[-0.1912995730,-0.0666245597,-0.0232956358,...
        -0.3242025611,-0.0103226790,-0.7257135266];
    
    problem.x_U=[-0.0939117369,-0.0327069633,-0.0114361657,...
        -0.1591557427,-0.0050675530,-0.3562633031];
    
    problem.light='B';
    
elseif and(strcmp(s,'white'),strcmp(type,'mixo'))
      
    problem.x_L=[-0.2323708429, -0.0274822664, -0.0101372740,...
        -0.2142613011,-0.0050952263,-0.5106530893];
    
    problem.x_U=[-0.0587726784, -0.0069509857, -0.0025639824,...
        -0.0541923005, -0.0012887163, -0.1291575545];
    
    problem.light='W';

elseif and(strcmp(s,'red'),strcmp(type,'mixo'))
    problem.x_L=[-0.1148631958, -0.0259126104, -0.0081871680,...
         -0.1778353475, -0.0057048919, -0.2510722950];
    
    problem.x_U=[-0.0290519137, -0.0065539785, -0.0020707494,...
        -0.0449792218, -0.0014429167, -0.0635027659];
    
    problem.light='R';
elseif and(strcmp(s,'blue'),strcmp(type,'mixo'))
    problem.x_L=[-0.1467973835, -0.0429727869, -0.0191441590,...
        -0.2698897263, -0.0037568544, -0.5018423882];
    
    problem.x_U=[-0.0371289070, -0.0108689445, -0.0048420597,...
        -0.0682621877, -0.0009502070, -0.1269290972];
    
    problem.light='B';
end

staticCoefs(1,:)=initialStaticCoefs(1,:);

changeCobraSolver('gurobi')
solution=optimizeCbModel(model);
sprintf('The Primaty growth rate is %d',solution.f)

an=animatedline(0,0,0);

an2=animatedline('Marker','o');

an3=animatedline('Marker','x');

Results=ess_kernel(problem,opts,model,miuExp,an,an2,fitnessFunctionScores, numberOfPointsToAverage,an3);

clear all 
 
fileName=datestr(datetime);
fileName=erase(erase(erase(fileName,' '),':'),'-');
 
load ess_report.mat

xL=problem.x_L';
xU=problem.x_U';

ff=[];
bestSolutions=[];

for i=1:(length(Results.Refset.x)-1)
    count=0;
    xfit=Results.Refset.x(i,:)';
    
   for j=1:(length(problem.x_0)-1)
       if or(xfit(j,1)<xL(j,1),xfit(j,1)>xU(j,1))
           count=1;
          break
       end
   end
   if count~=1
       bestSolutions=cat(1,bestSolutions,Results.Refset.x(i,:));
       ff=cat(2,ff,Results.Refset.f(i));
   end
end
%Think of duplicate fitness value

y=bestSolutions(find(ff==min(ff)),:);

clear count,fileName, i,j,

save(strcat('ResultsFile/ess_report',problem.light,fileName,'.mat'))
end
