    clear;
    clc;

    % ATENCAO - Antes de executar este arquivo, eh necessario ter executado o arquivo PrepareData.m
    
    % DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
    load 'eil51.tsp';
    load 'distances.mat';
    
    % Dimensoes do dataset
    [rows,columns]=size(distances); 
        
    % Variáveis do PSO...
    N=4;
    n_iter = 10;
    X = zeros(n_iter,rows+1); % Posicao (Particulas)
    V = [1 25; 25 50]; % Velocidade (Permutacoes)
    f = inf(n_iter, rows+1); % Custos

    % Inicial
    X(1,:) = [1:rows 1];
%    particle = randperm(rows,rows);
%    X(1,:) = [particle particle(1)]; % Com retorno a posicao 1....
    %V(1,:) = inf(1, rows+1);

    % Fitness inicial
    individual = X(1,:);
    f(1,1) = 0;
    for j=2:size(individual,2);
        f(1,1) = f(1,1) + distances(individual(j),individual(j-1));
    end;
%    % FITNESS (inicial) - Calcular aptidao de cada individuo (caminho) da populacao
%    individual = 0;
%    for i=1:1;
%        % Capturar cada individuo da populacao
%        individual = X(i,:);
%
%        % Percorrer colunas (pontos) do individuo a fim de totalizar o custo do
%        % trajeto
%        f(1,i) = 0;
%        for j=2:size(individual,2);
%            f(1,i) = f(1,i) + distances(individual(1,j),individual(1,j-1));
%        end;
%    end;

    % PBest / Gbest - INICIAL
    [Pbest,idxPbest] = min(f);
    Pbest = X(idxPbest(1),:);
    [Gbest,idxGbest] = min(Pbest);
  
    for i=2:n_iter;
    
        %r1 and r2 are random numbers...
        r1 = 0.3294;
        r2 = 0.9542;
                
        for j=1:N;

          % Transposicao...
          P = zeros(size(V,1), rows+1);
          for t=1:size(V,1);
            % Modelos...
            if(t==1)
              x = X(j, :);
            else;
              x = P(t-1,:);
            end;            
            v = V(t,:);
            % Swap...
            for y=2:size(v,2);
              vi = x(v(y-1));
              vj = x(v(y));
              x(v(y-1)) = vj;
              x(v(y)) = vi;              
              % Verificar posicao inicial/final
              if(v(y)==1 || v(y-1)==1); 
                x(size(x,2)) = x(1);
              end;
            end;  
            P(t,:) = x;      
          end;
          
          % Obtenção da Velocidade (Posição – Posição)
          A = P(1,:);
          for j=1:size(P(1,:),2);
            
              % Procurar pelo termo A[j] em B
              idxA = find(P(1,:)==A(j));
              idxB = find(P(2,:)==A(j));
            
          end;
        
%            % Velocidades (Atual = Deslocamento + Memoria Particula + Memoria Vizinhanca)
%            V(i,j) = V(i-1,j) + r1*(Pbest(j) - X(i-1,j)) + r2*(Gbest - X(i-1,j));
%            
%            % Novas posicoes        
%            X(i,j) = X(i-1,j) + V(i,j);
%            
%            % Fitnesss...
%            f(i,j) = -X(i,j)^2 + 2*X(i,j)+11;
            
            % Fitness....
%            individual = X(i,:);
%            if(j > 1)
%              f(i,j) = 0;
%              for j=2:size(individual,2);
%                  f(i,j) = f(1,1) + distances(individual(1,j),individual(1,j-1));
%              end;
%            end;
        end;
        
        % PBest / Gbest - Iterativo
        [Pbest,idxPbest] = min(f);
        Pbest = X(idxPbest(1),:);
        [Gbest,idxGbest] = min(Pbest);    
        
        % Verificar convergencia ...
        convergence = min(f);
        for i=2:N;        
            % Verificar se possui valores proximos...
            diff = convergence(i) - convergence(i-1);
            if ( diff > 0.2 || diff < 0.2 ); break; end;
            
            % Se atingiu a ultima posicao, convergiu
            if (i==4) break; end;
        end;
        
    end;
%
%    % Resultados...
%    [Pbest,idxPbest] = max(f);
%    [Gbest,idxGbest] = max(Pbest);  % Maior valor da fun��o
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