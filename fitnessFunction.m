function f=fitnessFunction(x,varargin)
%{

----------------------

Maybe have a look at the TUX Calculator, you might need to change the
functions there, speak to Alex about it this week.


--> CO2 Flux exchange does not actually change it is bounded
----------------------

%}
model=varargin{:};
miuExp=varargin{:,2};
an=varargin{:,3};
an2=varargin{:,4};
fitnessFunctionScores=varargin{:,5};
numberOfPointsToAverage=varargin{:,6};
an3=varargin{:,7};
%{
  ------------------------------------  
    Important things to do to fix some bugs:
    1. The the multiplications with the multcoef on the GeneticAlgo file to
    ensure that units are consistent and the fitness function produces
    
    2. Total carbon should be a percentage in g/gDCW, thus static coefs
    have to be inputed in the fitness function as g/gDCW and expectations
    as well
  ------------------------------------
%}

load iteration.mat

if iteration~=0     
   
    model=GroupToFBACoef(x,'ff',model);
    
end

solution=optimizeCbModel(model);
load staticCoefs.mat %Could potentially load them earlier and pass them inside the GroupToFBACoef() Function

fluxes=solution.x;
miuFba=solution.f;


sprintf('Calculated Difference: %d | Expectation(1): %d | %d',(miuFba-miuExp)^2,x(1,1))

absoluteTotalSum=abs(abs(sum(x)+sum(staticCoefs(1,:)))-1);

f=((miuExp-miuFba)/miuExp)^2+absoluteTotalSum;

%{ 
Friday 28th of June 2019

1. Normalised stochiometric coefficients should add up to one

2. Ensure that you understand the scatter search and then 
ensure that it creates generations so actually pick the best fittness
funciton to plot out of the generation. READ THE PAPER.L

%}

fitnessFunctionScores(1,(iteration+1))=f;

try 
    
    a=fitnessFunctionScores;
    b=numberOfPointsToAverage;
   
    av=mean(a((length(a)-b):length(a)));
    sd=std(a((length(a)-b):length(a)));
    
    addpoints(an2,iteration,av)
    drawnow
    
    addpoints(an3,iteration,sd)
    drawnow
    
catch
   
end

addpoints(an,iteration,f)
drawnow

% addpoints(an2,iteration,miuFba )
% drawnow

iteration=iteration+1;

save('iteration.mat','iteration')

disp(iteration)
disp(f)

end
