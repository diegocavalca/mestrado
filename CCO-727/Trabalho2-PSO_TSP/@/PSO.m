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
    popSize = 50;
    numIter = 1000;
    X = zeros(popSize,rows+1); % Posicao (Particulas)
    V = cell(1, popSize); % Velocidade (Permutacoes)
    Vmax = 15;
    f = inf(numIter, popSize); % Custos
    gBestScore = inf;
    pBestScore = inf(popSize, 1); 

    %% Inicializacao
    % Populacao...
    X(1,:) = [1:rows 1];
    parfor i=2:popSize;
        X(i,:) = [randperm(rows,rows) 0];
        V{i} = [randperm(51,2)];
    end;
    X(:,rows+1) = X(:,1); % Destino...

    %% Iteracoes...
    for t=1:numIter;
    %t=0;
    %while(gBestScore>500 && t<1000);
      %t = t + 1;
        
        % Avaliar particulas...
        for i=1:popSize;
            cost = Fitness(X(i,:), distances);
            if(pBestScore(i)>cost)
                pBestScore(i)=cost;
                pBest(i,:)=X(i,:);
            end
            if(gBestScore>cost)
                gBestScore=cost;
                gBest=X(i,:);
            end;
            f(t,i) = cost;
        end;

        % Atualizar particulas (velocidade e posicao)...        
        parfor i=1:popSize;
        
            % Coeficientes de confianca...
            alpha = rand(1);
            beta = rand(1);
       
            % Extrair operadores de troca... 
            Vp = SwapOperators(pBest(i,:), X(i,:), alpha); % (pBest - Xi)
            Vg = SwapOperators(gBest, X(i,:), beta); % (gBest - Xi)
            
%            %% Atualizando particula...
%            % Velocidade....
%            V{i} = [V{i}; Vp];
%            V{i} = [V{i}; Vg];
%            %[~,ssIdx] = unique(V{i},'rows');
%            %V{i} = V{i}(sort(ssIdx),:);
%            
%            % Controle de velocidade...
%            %if size(V{i},1) > Vmax;
%            %  V{i} = V{i}(1:Vmax,:);
%            %end;
%            
%            % Posicao
%            parfor v=1:size(V{i},1); 
%              vel = V{i}(v,:);%V(v,:);
%              X(i, [vel(1) vel(2)]) = X(i, [vel(2) vel(1)]); % Operacoes de troca...
%              if( X(i, 1) ~= X(i, rows+1) ); X(i, rows+1) = X(i, 1); end;              
%            end;

            % Velocidade...
            Vt = [randperm(51,2)];
            Vt = [Vt; Vp];
            Vt = [Vt; Vg];    
            % Controle de velocidade...
            if length(Vt) > Vmax;
              Vt = Vt(1:Vmax,:);
            end;
            
            % Posicao...
            for v=1:size(Vt,1);
              vel = Vt(v,:);
              X(i, [vel(1) vel(2)]) = X(i, [vel(2) vel(1)]); % Operacoes de troca...
              if( X(i, 1) ~= X(i, rows+1) ); X(i, rows+1) = X(i, 1); end;
            end;        
            
            %disp( strcat('-----> Pbest(',num2str(i),'): ', num2str(pBestScore(i))) );
        end;
        histBest(t) = gBestScore;
        
    end;
    
    % Resultados...
    plot(histBest);
    
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