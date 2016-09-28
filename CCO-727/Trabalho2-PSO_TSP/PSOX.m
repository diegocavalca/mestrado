    clear;
    clc;

    tic;
    
    % ATENCAO - Antes de executar este arquivo, se faz necessario ter executado o arquivo PrepareData.m
    
    % DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
    load 'eil51.tsp';
    load 'distances.mat';
    
    % Dimensoes do dataset
    [rows,columns]=size(distances); 
        
    % Variaveis do PSO...
    swarmSize = 100;
    numIter = 500;
    X = zeros(swarmSize, rows); % Posicao (Particulas)
    V = cell(1, swarmSize); % Velocidade (Permutacoes)
    Vmax = 15;
    gBestScore = inf;
    pBestScore = inf(swarmSize, 1); 
    c1 = 0.9;
    c2 = 0.05;
    c3 = 0.05;

    %% Inicializacao
%     % Nuvem...
%     X(1,:) = 1:rows;
%     for i=2:swarmSize;
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
%     end;

    load 'X.mat';

    %% Iteracoes...
    for t=1:numIter;
        
        % Avaliar particulas...
        for i=1:swarmSize;
            cost = Fitness(X(i,:), distances);
            if(pBestScore(i)>cost)
                pBestScore(i)=cost;
                pBest(i,:)=X(i,:);
            end
            if(gBestScore>cost)
                gBestScore=cost;
                gBest=X(i,:);
            end;
        end;

        % Atualizar particulas (velocidade e posicao)...        
        for i=1:swarmSize;
            
%             % Inversao
%             invI = randi([1 floor(rows/2)]);
%             invF = randi([invI+1 rows]);
%             X(i,invI:invF) = fliplr(X(i,invI:invF));

            % Coeficientes de confianca...
            w = c1*rand(1);
            alpha = c2*rand(1);
            beta = c3*rand(1);
       
            % Deslocamento...
            Vd = Memory(V{i}, w);
            
            % Operadores de troca... 
             % (pBest - Xi)
            Vp = SwapOperators(pBest(i,:), X(i,:));
            Vp = Memory(Vp, alpha);
             % (gBest - Xi)
            Vg = SwapOperators(gBest, X(i,:));
            Vg = Memory(Vg, beta);
            
            %% Atualizando particula...
            % Velocidade....
            V{i} = [Vd; Vp; Vg];
            %V{i} = unique(V{i},'rows','stable');
            % Controle de velocidade...
            if size(V{i},1) > Vmax;
                V{i} = V{i}(1:Vmax,:);
            end;

            % Posicao
            X(i, :) = Movement(X(i,:), V{i});
            
            % Resetar se for melhor globl
            if isequal(X(i, :), gBest);% || isequal(X(i, :), pBest(i, :));
              X(i, :) = randperm(rows, rows);
            end;
            
        end;
        
        % Atualizando confianca...
        c1 = c1 * 0.95; 
        c2 = c2 * 1.01; 
        c3 = 1 - (c1+c2);
        
        histBest(t) = gBestScore;
        
    end;
    
    % Resultados...
    figure;
    plot(histBest);
    figure;
    rte = gBest([1:rows 1]);
    plot(rte',rte','r.-'); % Caminho
    plot(eil51(rte,2),eil51(rte,3),'r.-'); % Pontos (cidades)   
    
    toc;
%
%    % Resultados...
%    [Pbest,idxPbest] = max(f);
%    [Gbest,idxGbest] = max(Pbest);  % Maior valor da funcao
%    % Melhor X
%    Xbest = X(idxPbest(1),:); 
%
%    % Plotando...
%    fig=figure; 
%    hax=axes; 
%
%    % Linha...
%    x=-2:0.1:2;
%    y= -x.^2 + 2*x + 11;
%    plot(x,y);
%
%    % Estrela...
%    hold on;
%    plot(Xbest(idxGbest), Gbest, '*');

    % Linha do pc
    %line([Xbest(idxGbest) Xbest(idxGbest)],get(hax,'YLim'),'Color',[1 0 0])