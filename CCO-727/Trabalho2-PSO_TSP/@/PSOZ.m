%% Iteracoes de teste - gerando dados do relatorio
for t = 1:10;
%% Fim dos testes pro relatorio
    
    clear;
    clc;

    tic;
    
    % ATENCAO - Antes de executar este arquivo, se faz necessario ter executado o arquivo PrepareData.m
    
    % DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
    load 'eil51.tsp';
    load 'distances.mat';
    
    % Dimensoes do dataset
    [rows,columns]=size(distances); 
        
    %% Variaveis do PSO...
    swarmSize = 40;
    numIter = 10;
    cPr = 0.2;
    w = 0.9; % Fator de inercia 
    alpha = 0.8; % Fator individual - c2
    beta = alpha; % Fator social - c3
    %%% INTUICAO sobre coeficientes
    %%% w = 0.02, alpha = 1.5 e beta = 1.5. Neste caso o
    %%% algoritmo faria com que suas particulas pouco procurassem por regioes inexploradas do
    %%% espaco de busca tendendo a seguir as melhores posicoes ja encontradas ate o momento pelo
    %%% algoritmo.
    %%%%
    
    X = zeros(swarmSize, rows); % Posicao (Particulas)
    V = cell(1, swarmSize); % Velocidade (Permutacoes)
    %F = inf(swarmSize, 1); % Custos (Funcao objetivo)
    gBestScore = inf;
    pBestScore = inf(swarmSize, 1);     

    %% Inicializacao
    % Nuvem aleatoria - Metodo do Vizinho mais Proximo (Goldbarg e Luna, 2005)...
    for i=1:swarmSize;
        X(i,:) = randperm(rows, rows);
        % Avaliacao...
        cost = Fitness(X(i,:), distances);
        %F(i) = cost;
        if(pBestScore(i)>cost)
            pBestScore(i)=cost;
            pBest(i,:)=X(i,:);
        end
        if(gBestScore>cost)
            gBestScore=cost;
            gBest=X(i,:);
        end;
%         particle = zeros(1, rows);
%         % Cidade inicial aleatoria...
%         particle(1) = randperm(rows, 1); 
%         for j=2:rows;
%             % k(+i) vizinhos mais proximos
%             k = 1;
%             c = particle(1);
%             target = 1;
%             while ( isempty(find(particle==c))==0 ); % Verificar se cidade ja esta na particula...
%                 neighbours = distances(particle(j-1),:);
%                 neighbours( neighbours==0 ) = inf;
%                 [~,idx]=sort(neighbours(:));
%                 c = idx(k);
%                 k = k+1;
%             end;
%             particle(j) = c;
%         end;
%         X(i,:) = particle;
% 
%         % Avaliacao...
%         cost = Fitness(X(i,:), distances);
%         F(i) = cost;
%         if(pBestScore(i)>cost)
%             pBestScore(i)=cost;
%             pBest(i,:)=X(i,:);
%         end
%         if(gBestScore>cost)
%             gBestScore=cost;
%             gBest=X(i,:);
%         end;
    end;

    %% Iteracoes...
    for t=1:numIter;
        
        fprintf('\n Iter %d: - gBest: %.2f \n', t, gBestScore);
                
        % Atualizar particulas (velocidade e posicao)...        
        for i=1:swarmSize;
               
            % Movimento da nuvem... 
            fprintf('.');
            [X(i,:), xCost] = LocalSearch(X(i,:), w, distances); % M1
            [X(i,:), xCost, gBest, gBestScore] = PathRelinking (X(i,:), xCost, gBest, gBestScore, beta, cPr, distances); %gBest - M3
            [X(i,:), xCost, pBest(i,:), pBestScore(i)] = PathRelinking (X(i,:), xCost, pBest(i,:), pBestScore(i), alpha, cPr, distances); %pBest - M2  
            
            % Avaliacao...
            cost = Fitness(X(i,:), distances);
            %F(i) = cost;
            if(pBestScore(i)>cost)
                pBestScore(i)=cost;
                pBest(i,:)=X(i,:);
            end
            if(gBestScore>cost)
                gBestScore=cost;
                gBest=X(i,:);
            end;
            
        end;
        
        % Ponderar fator de inercia iterativamente
        %w = ( (numIter - t)*(0.4-0.9)/ numIter ) + 0.9;
        
        histBest(t) = gBestScore;
        
    end;
    
    % Resultados...
    figureHistory = figure;
    plot(histBest);
    figureBestRoute = figure;
    rte = gBest([1:rows 1]);
    plot(rte',rte','r.-'); % Caminho
    plot(eil51(rte,2),eil51(rte,3),'r.-'); % Pontos (cidades)   
    
    timeExec = toc;
    
    %% !!!!! Iteracoes de teste - gerando dados do relatorio !!!!!

       % Salvar figuras...
       folderResults = sprintf('Results/Iter_%d-Swarm_%d-Cpr_%d-W_%d-C_%d/', numIter, swarmSize, cpr, w, beta);
       mkdir(folderResults);
       DateString = datestr(datetime('now'));
       date = str2num(datestr(now,'ddmm'));
       hour = str2num(datestr(now,'HHMM'));
       datestr = datestr(now,'ddmm-HHMMSS');
       saveas(figureBestRoute, sprintf('%s/bestRoute-COST_%d-%s.jpg', folderResults, gBestScore, datestr)); % BestRoute
       saveas(figureHistory, sprintf('%s/distHistory-COST_%d-%s.jpg', folderResults, gBestScore, datestr)); % History
       
       % Salvar dados do teste...
       dataSummary = [date hour numIter swarmSize w alpha beta cpr gBestScore timeExec];
       dlmwrite('Results/Summary.csv', dataSummary, '-append', 'delimiter', ';');
    
       % Variaveis
       save(sprintf('%s/gBest-%s.mat', folderResults, datestr), 'gBest');
       save(sprintf('%s/histBest-%s.mat', folderResults, datestr), 'histBest');
        
end;
    %% !!!!! Fim dos testes pro relatorio !!!!!