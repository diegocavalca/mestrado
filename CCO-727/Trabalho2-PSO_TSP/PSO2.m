    clear;
    clc;

    %tic;
    
    % ATENCAO - Antes de executar este arquivo, se faz necessario ter executado o arquivo PrepareData.m
    
    % DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
    load 'eil51.tsp';
    load 'distances.mat';
    
    % Dimensoes do dataset
    [rows,columns]=size(distances); 
        
    % Variaveis do PSO...
    N=4;
    popSize = 50;
    n_iter = 10;
    X = zeros(popSize,rows+1); % Posicao (Particulas)
    %V = inf(popSize, 1); % Velocidade (Permutacoes)
    f = inf(n_iter, popSize); % Custos
    gBestScore = inf;
    pBestScore = inf(popSize, 1); 

    %% Inicializacao
    % Populacao...
    X(1,:) = [1:rows 1];
    for i=2:popSize;
        X(i,:) = [randperm(rows,rows) 0];
    end;
    X(:,rows+1) = X(:,1); % Destino...
        
    %% Iteracoes...
    %for t=1:n_iter;
    t=0;
    while(gBestScore>500 && t<1000);
      t = t + 1;
        
        %r1 and r2 are random numbers...
        c2 = rand(1);
        c3 = rand(1);
                
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
        for i=1:popSize;
            
            % Operadores de troca para calcular = pBest - x(t-1)
            %if( X(i,:) ~= pBest(i,:) );
            SS = [];
            Paux = pBest(i,:);
            x = X(i,:);                
            for c=1:size(Paux,2)-1;
                % Elementos x em Paux
                idxP2 = find(x([1:rows])==Paux(c));
                % verificar se ja n faz parte - sum(ismember(SS,SO,'rows'))==0
                if( c ~= idxP2 );
                    SO = [c idxP2];
                    SS = [SS; SO]; % SO
                    % Atualizar x
                    x([c idxP2]) = x([idxP2 c]); 
                    if( x(1) ~=x(size(Paux,2)) ); x(size(x,2)) = x(1); end;
                end;
            end;            
            % Memoria da Particula
            if(c2>0 && c2<1)
              Vp = SS([1:ceil( c2 * size(SS,1))],:);                
            else
              Vp = [];                     
            end;
            
            % Operadores de troca para calcular = gBest - x(t-1)
            %if( X(i,:) ~= pBest(i,:) );
            SS = [];
            Paux = gBest;
            x = X(i,:);                
            for c=1:size(Paux,2)-1;
                % Elementos x em Paux
                idxP2 = find(x([1:rows])==Paux(c));
                % verificar se ja n faz parte - sum(ismember(SS,SO,'rows'))==0
                if( c ~= idxP2 );
                    SO = [c idxP2];
                    SS = [SS; SO]; % SO
                    % Atualizar x
                    x([c idxP2]) = x([idxP2 c]); 
                    if( x(1) ~=x(size(Paux,2)) ); x(size(x,2)) = x(1); end;
                end;
            end;            
            % Memoria da Vizinhanca
            if(c3>0 && c3<1)
              Vg = SS([1:ceil( c3 * size(SS,1))],:);                
            else
              Vg = [];                 
            end;
            
            %% Atualizando particula...
            % Velocidade....
            v = [randperm(51,2)];
            %v = [2 5; 23 48];
            Vt = [];
            Vt = [Vt; v];
            Vt = [Vt; Vp];
            Vt = [Vt; Vg];
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
    
    plot(histBest);
    %toc;
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