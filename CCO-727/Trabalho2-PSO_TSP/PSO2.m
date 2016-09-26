    clear;
    clc;

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
    X = zeros(n_iter,rows+1); % Posicao (Particulas)
    V = [1 25; 25 50]; % Velocidade (Permutacoes)
    f = inf(n_iter, popSize); % Custos

    %% Inicializacao
    % Populacao...
    X(1,:) = [1:rows 1];
    for i=2:popSize;
        X(i,:) = [randperm(rows,rows) 0];
    end;
    X(:,52) = X(:,1); % Destino...

    %% Iteracoes...
    for t=1:n_iter;
        
        %r1 and r2 are random numbers...
        c2 = 0.3294;
        c3 = 0.9542;
        
        % Fitness (aptidao)
        for i=1:popSize;
            f(t,i) = Fitness(X(i,:), distances);
        end;

        % Avaliar...
        [Pbest,idxPbest] = min(f);
        Pbest = X(idxPbest(1),:);
        [Gbest,idxGbest] = min(Pbest);
        Gbest = X(idxGbest(1),:);
        
        for i=1:popSize;
            
            % Operadores de troca para calcular = Gbest - x(t-1)
            if( X(i,:) ~= Gbest );
                SG = [];
                x = X(i,:);
                Paux = Gbest;
                for c=1:size(x,2);
                    % Elementos x em Paux
                    idxP2 = find(Paux==x(c));
                    % verificar se ja n faz parte - sum(ismember(SS,SO,'rows'))==0
                    if( c ~= idxP2 );
                        SO = [c idxP2(1)];
                        SG = [SG; SO]; % SO
                        % Atualizar Paux
                        Paux([c idxP2(1)]) = Paux([idxP2(1) c]); 
                        if( Paux(1) ~=Paux(size(Paux,2)) ); Paux(size(Paux,2)) = Paux(1); end;
                    end;
                end;
                
                % Memoria da Vizinhanca
                if(c2==0);
                    Vg = [];    
                elseif(c2>0 && c2<1)
                    SG = SG([1:ceil( c2 * size(SG,1))],:);                
                elseif (c>1)
                    
                else
                    SG([1:ceil(0.5)], :) = [];
                    % inverter
                end;

            end;
            

            % Operadores de troca para calcular = Pbest - x(t-1)
            if( X(i,:) ~= Pbest );
                SP = [];
                x = X(i,:);
                Paux = Pbest;
                for c=1:size(x,2);
                    % Elementos x em Paux
                    idxP2 = find(Paux==x(c));
                    % verificar se ja n faz parte - sum(ismember(SS,SO,'rows'))==0
                    if( c ~= idxP2 );
                        SO = [c idxP2(1)];
                        SP = [SP; SO]; % SO
                        % Atualizar Paux
                        Paux([c idxP2(1)]) = Paux([idxP2(1) c]); 
                        if( Paux(1) ~=Paux(size(Paux,2)) ); Paux(size(Paux,2)) = Paux(1); end;
                    end;

                end;
            end;
            
            
            
        end;


        
        % Percorrer particulas...
        for j=1:1;

          % Transposicao...
          P = zeros(size(V,1), rows+1);
          for t=1:size(V,1);
            % Modelos...
            if(t==1)
              x = X(j, :);
            else
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
          % P(size(V,1),:)
          
        
          
        end;
        
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