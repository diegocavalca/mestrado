clear;close all;clc;    %Clears variables, closes windows, and clears the command window
tic                     % Begins the timer

% DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
load 'eil51.tsp'
load 'dist.mat'

% Dimensoes do dataset
[d,c]=size(dist); 

%% Select Target String
target  = 'Hello, world!';
% *Can Be Any String With Any Values and Any Length!*

%% Parameters                    
numGen  = 10000;
popSize = 500;                                 % populationulation Size (100-10000 generally produce good results)
genome  = c;                                   % Genome Size
mutRate = .15;                                 % Mutation Rate (5%-25% produce good results)
S       = 4;                                    % Tournament Size (2-6 produce good results)
count   = 1;                                   % Used for plotting purposes
best    = Inf;                                  % Initialize Best (arbitrarily large)

selection = 1;                                  % 0: Tournament / 1: 50% Truncation

crossover = 0;                                  % 0: Uniform crossover
                                                % 1: 1 point crossover
                                                % 2: 2 point crossover
                                                
plotting = 1;                                   % 0: no graph
                                                % 1: plot fitness/gen
% PARAMETROS, variaveis e configuraoes gerais
 %1e6 Limite de iteracoes das operacoes genetica

% INICIO - Gerar populacao inicial
population = zeros(popSize, d);
population(1,:) = (1:d);
for i = 2:popSize;
    population(i,:) = randperm(d,d);
end
%save initialpopulation initialpopulation                            
                                                
  %% Initialize populationulation
  %population = round(rand(popSize,genome)*(MaxVal-1)+1); % Creates populationulation With Corrected Genome Length

  %initF = min(sum(abs(bsxfun(@minus,population,ideal)),2));   % Initial fitness for plotting

for Gen = 1:numGen                                 % A Very Large Number Was Chosen, But Shouldn't Be Needed
    
    
    
    %% Fitness
    
    % The fitness function starts by converting the characters into integers and then
    % subtracting each element of each member of the population from each element of 
    % the target string. The function then takes the absolute value of 
    % the differences and sums each row and stores the function as a mx1 matrix.
    
    %F = sum(abs(bsxfun(@minus,population,ideal)),2);       
    
     
    
    % Finding Best Members for Score Keeping and Printing Reasons
    %[current,currentGenome] = min(F);   % current is the minimum value of the fitness array F
                                        % currentGenome is the index of that value in the F array
    
    % FITNESS - Calcular aptidao de cada individuo (caminho) da populacao
    individual = 0;
    for i=1:popSize;
        % Capturar cada individuo da populacao
        individual = population(i,:);

        % Percorrer colunas (pontos) do individuo a fim de totalizar o custo do
        % trajeto
        total = 0;
        for j=2:size(individual,2);
            total = total + dist(individual(1,j),individual(1,j-1));
        end;

        % Calcular o custo de voltar ao ponto 1
        total = total + dist(individual(1,d),individual(1,1));
        % Guardando a aptidao do individuo
        totalDist(i,:) = [i, total];
    end
    %fitness = sortrows(fitness,2);
    %save fitness fitness
    %disp(max(totalDist));
 
    % Melhor rota calculada na populacao 
    [minDist,idxRoute] = min(totalDist);
    
    % Stores New Best Values and Prints New Best Scores
    if minDist < best
        best = minDist(2);                     % Makes new best
        bestRoute = population(idxRoute,:);  % Uses that index to find best value
    
        % Very Ugly Plotting Implementation -- Needs to be Cleaned up Badly
  %*********************************************************************************************
        %disp(count);
        if plotting == 1
          B(count) = best;                    % Stores all best values for plotting
          G(count) = Gen;                     % Stores all gen values for plotting
          count = count + 1;                  % Increments number of best found
        end
  %*********************************************************************************************      
        
        % Plotar a melhor rota atual
        %rte = bestRoute([1:d 1]);
        %plot(rte',rte','r.-'); % Caminho
        %plot(eil51(rte,2),eil51(rte,3),'r.-'); % Pontos (cidades)        
        %title( {sprintf('Results - Dist. = %d, Gener. = %d',minDist,Gen), sprintf('Params - PopSize = %d, NumGen. = %d',popSize,numGen) } );
        %title( {sprintf('Results - Dist. = %d, Gener. = %d',minDist(2),Gen)} );
        %drawnow;
        
        %fprintf('Gen: %d  |  Fitness: %d  |  ',Gen, best);  % Formatted printing of generation and fitness
        %disp(char(bestRoute));                             % Best genome so far
    elseif best == 0
        break                                               % Stops program when we are done
    end

    %% Selection
    
    % TOURNAMENT
    if selection == 0
      T = round(rand(2*popSize,S)*(popSize-1)+1);                     % Tournaments
      [~,idx] = min(totalDist(T),[],2);                               % Index to Determine Winners         
      W = T(sub2ind(size(T),(1:2*popSize)',idx));                     % Winners
    
    % 50% TRUNCATION
    elseif selection == 1
      [~,V] = sort(totalDist(:,2),'descend');                                      % Sort Fitness in Ascending Order
      V = V(popSize/2+1:end);                                         % Winner Pool
      W = V(round(rand(2*popSize,1)*(popSize/2-1)+1))';               % Winners    
    end
    
    %% Crossover
    
    % UNIFORM CROSSOVER
    if crossover == 0
      idx = logical(round(rand(size(population))));                          % Index of Genome from Winner 2
      population2 = population(W(1:2:end),:);                                       % Set population2 = population Winners 1
      P2A = population(W(2:2:end),:);                                        % Assemble population2 Winners 2
      population2(idx) = P2A(idx);                                           % Combine Winners 1 and 2
    
    % 1-POINT CROSSOVER
    elseif crossover == 1
      population2 = population(W(1:2:end),:);                                       % New populationulation From population 1 Winners
      P2A = population(W(2:2:end),:);                                        % Assemble the New populationulation
      Ref = ones(popSize,1)*(1:genome);                               % The Reference Matrix
      idx = (round(rand(popSize,1)*(genome-1)+1)*ones(1,genome))>Ref; % Logical Indexing
      population2(idx) = P2A(idx);                                           % Recombine Both Parts of Winners
    
    % 2-POINT CROSSOVER
    elseif crossover == 2
      population2 = population(W(1:2:end),:);                                       % New population is Winners of old population
      P2A  = population(W(2:2:end),:);                                       % Assemble population2 Winners 2
      Ref  = ones(popSize,1)*(1:genome);                              % Ones Matrix
      CP   = sort(round(rand(popSize,2)*(genome-1)+1),2);             % Crossover Points
      idx = CP(:,1)*ones(1,genome)<Ref&CP(:,2)*ones(1,genome)>Ref;    % Index
      population2(idx)=P2A(idx);                                             % Recombine Winners
    end
    %% Mutation 
    idx = rand(size(population2))<mutRate;                                 % Index of Mutations
    population2(idx) = round(rand([1,sum(sum(idx))])*(genome-1)+1);        % Mutated Value
    
    %% Reset populationlulations
    population = population2;                                                   
    
    disp(strcat('Gen: ',num2str(Gen),' - Min. Dist: ',num2str(best)));
   
end

toc % Ends timer and prints elapsed time

% Graphs Fitness Curve if Plotting is Turned On
if plotting == 1
% Plot Best Values/Gen
figure(1)
plot(G(:),B(:), '-r')
axis([0 Gen 0 1300])
title('Fitness Over Time');
xlabel('Fitness');
ylabel('Generation');                  
end


