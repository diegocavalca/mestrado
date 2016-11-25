% % IMPORTANTE: Testar possiveis combinações de parametros PSO
% for nIter = 30%[30, 50]
%     for swarmSize = 15%[15, 30, 50, 100]
%         for wMax = 1.2%[1.2, 1.5, 1.6]
%             for wMin = 0.2%[0.2, 0.4, 0.6]
%                 for cX = 1.2%[1.2, 1.4944, 2]
%                     c1 = cX;
%                     c2 = c1;
                    
                    % %% Iteracoes de teste - gerando dados do relatorio
                    % (para cada combinacao de parametros do PSO)
                    clc; 
                    clear all;
                    
                    % Importando dados do benchmark
                    dataset = '10x10'; % ALTERAR DATASET PRA TESTAR EM DIFERENTES CONJUNTOS (Ex.: 8x8, 10x10 ou 15x10)
                    global Tij;
                    global Oij;

                    Tij = importdata(sprintf('benchmarks/tempos%s.txt', dataset)); % Tempos das operacoes
                    Oij = importdata(sprintf('benchmarks/op%s.txt', dataset)); % Operacoes por job

                    % ORGANIZANDO MAQUINAS - Melhores tempos tem prioridade 1, maior tem
                    % prioridade M, sendo M > 0, senao a maquina M nao eh factivel para Oij
                    global Mij;
                    Mij = MachinesPrior(Tij);

                    % Variaveis do problema
                    global n; % Relacao completa de JobxOperacoes
                    global m; % Numero de Maquinas
                    [n,m] = size(Tij);
                    
                    global jobs; % Numero de Jobs
                    jobs = size(Oij, 2);

                    % Configuracoes SA (XIA;WU) / 
                    global nIterTemp;
                    nIterTemp = 20;
%                     %%%%%%%%%%%%%%% 8x8 %%%%%%%%%%%%%%%%


%                     %%%%%%%%%%%%%%% 8x8 %%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%% 10x10 %%%%%%%%%%%%%%%
                    global t0;   % Temp. Inicial
                    t0 = 5;
                    global tEnd; % Temp. final
                    tEnd = 0.01;
                    global B;    % Fator de resfriamento
                    B = 0.9;  
                    %%%%%%%%%%%%%% 10x10 %%%%%%%%%%%%%%%
%                     %%%%%%%%%%%%%% 15x10 %%%%%%%%%%%%%%%
%                     global t0;   % Temp. Inicial
%                     t0 = 10;
%                     global tEnd; % Temp. final
%                     tEnd = 0.01;
%                     global B;    % Fator de resfriamento
%                     B = 0.95;  
%                     %%%%%%%%%%%%%% 15x10 %%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %%%%% CONFIGURACOES DINAMICAS SA %%%%%
%                     % Numero de Iteracoes por temperatura
%                     global nIterTemp;
%                     nIterTemp = 20;
%                     % Fator de resfriamento
%                     global B;
%                     B = 0.9;
%                     % Temp. inicial
%                     maxChange = max(Oij);
%                     avgExeTime = sum(Oij)/m;
%                     if( avgExeTime > maxChange );
%                         maxChange = avgExeTime;
%                     end;
%                     global t0;
%                     t0 = -maxChange/log(B);
%                     % Temp. final
%                     global tEnd;
%                     tEnd = 0.9^40;
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Configuracoes PSO (* = XIA; WU, | = Gabriel)
                    nIter     = 30;  %Possiveis: [30|, 50*]
                    swarmSize = 50;  %sum(Oij)+jobs;  %Possiveis: [15, 30|, 50, 100*]
                    wMax      = 1.2; %Possiveis: [1.2*|, 1.5, 1.6]
                    wMin      = 0.4; %Possiveis: [0.2, 0.4*|, 0.6]
                    c1        = 2;   %Possiveis: [1.2, 1.4944, 2*|]
                    c2        = c1;
                    
                    % Maquinas descartadas (piores) para geracao de solucao 
                    % (apenas X melhores niveis)
                    if m > 5 ;
                        if isempty(find(Tij == 0));
                           discardMachines = m-3;     % Todas maquinas factiveis
                        else
                           discardMachines = (m-1)-3; % Pelo menos uma NAO FACT.
                        end;  
                    else
                        discardMachines = 0;
                    end;
                    %%%%% CONFIGURACOES DINAMICAS %%%%%
                                        
                    for tst = 100:101;
                    %% Testes pro relatorio
                    
                        clc;
                        tic;

                        % Nuvem (populacao) e solucao inicial
                        X = zeros(swarmSize, n);
                        M = cell(swarmSize, m);
                        P = X;

                        % Variaveis objetivo
                        % Local
                        pBestX = zeros(swarmSize, n);
                        pBestM = M;
                        pBestCost = Inf(1, swarmSize);
                        % Global
                        gBestX = zeros(1, n);
                        gBestM = cell(1,m);
                        gBestCost = Inf;
                        % AIW-APPROACH
                        swarmCost = Inf(1, swarmSize);
                        
                        % Variaveis adicionais
                        %discardMachines = (m-1)-3; % Maquinas a seremdescartadas (piores) / apenas 3 melhores      
                        Sol = zeros(1, n);         % Controle de estagnacao
                        histBest = zeros(1, nIter); % Historico de iteracoes
                        v = ones(swarmSize, n);     % Velocidade da equacao 1a (PSO) 

                        % ROTEAMENTO - Gerar populacao do enxame (roteamentos)
                        fprintf('Gerando populacao inicial... \n');
                        for i=1:n;

                            % Maquinas factiveis na ordem de melhor >> pior, 
                            [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, discardMachines);

                            X(:, i) = machines;
                            P(:, i) = priorities;

                        end;
                        
                        % AVALIACAO INICIAL dos individuos
                        fprintf('Avaliacao da populacao inicial');
                        for i=1:swarmSize;

                            % Simulated Annealing (Avaliacao da particula otimizada pelo SA)
                            [M(i,:), makespan, X(i, :), ~] = SA(X(i, :), @Scheduler, @Fitness, @Neighbor);
                            
                            % FITNESS
                            pBestCost(i) = makespan;
                            pBestX(i, :) = X(i, :);
                            pBestM(i, :) = M(i, :);

                            % Solucoes ja encontradas
                            P(i, :) = ParticlePosition(X(i, :), Mij);
                            
                            % AIW-APPROACH
                            swarmCost(i) = makespan;
                            
                            fprintf('.');

                        end;

                        % Melhor global (inicial)
                        [gBestCost, idx] = min(pBestCost);
                        gBestX = pBestX(idx, :);
                        gBestM = pBestM(idx, :);
                        fprintf(' \nMelhor inicial: %.0f... \n', gBestCost);
                        
                        % AIW-APPROACH
                        fBest = min(swarmCost);
                        fWorst = max(swarmCost);
                        fX = round(sum(swarmCost)/length(swarmCost));                        

                        % PASSO 3
                        fprintf('Aplicando PSO... \n');
                        for iter=1:nIter;
                        %iter = 0;
                        %while gBestCost > 7;
                            %iter = iter + 1;

                          % Insere particulas no registro de solucoes
                          Sol = [Sol; P];

                          % Movimento da nuvem (Exploracao Global)...
                          w = wMax - ( (wMax - wMin)/nIter ) * iter;
                          
                          %w = wMin + (wMax - wMin) * ( (fX - fWorst) / (fBest - fWorst));
                          r1 = rand(swarmSize, 1);
                          r2 = rand(swarmSize, 1);

                          % Elementos particulares da equacao 1a
                          x = P;
                          pBest = ParticlePosition(pBestX, Mij);
                          gBest = ParticlePosition(gBestX, Mij);

                          %%%%%%%%%%%%%% Insere particulas no registro de solucoes
                          %Sol = [Sol; pBest; gBest];
                          %%%%%%%%%%%%%%%%%%%%%%

                          % Velocidade
                          v = w*v + c1 * bsxfun(@times, r1, pBest - x) + c2 * bsxfun(@times, r2, (bsxfun(@minus, gBest, x)));

                          % Posicao
                          x = round(x + v);

                          % Validar vMin e vMax
                            % Validar vMin e vMax
                            for i=1:n;

                              % Maquinas factives (3 melhores)
                              fMach = find(Tij(i, :));% Maquinas factives para operacao Oij (tempo > 0)
                              machinesOp = Mij(i, ismember(Mij(i, :), fMach));% Maquinas factiveis na ordem de melhor >> pior
                              machinesOp = machinesOp(1:length(machinesOp)-discardMachines);
                              [~, priorities] = ismember(machinesOp, Mij(i, :));

                              vMin = priorities(1);
                              vMax = priorities(end);

                              x_aux = x(:, i);
                              x_aux(x_aux < vMin) = vMin;
                              x_aux(x_aux > vMax) = vMax;
                              x(:, i) = x_aux;    

                                % Operacoes que n possuem maquinas factiveis...
                                wrongOps = find(~ismember(x(:,i),Mij(i,:)));
                                for w=1:length(wrongOps)
                                    % Atribuindo uma maquina (rand) factivel para a operacao em questao
                                    idx = randi([1 vMax],1,1); % PODE MELHORAR COM ROLETA
                                    x(wrongOps(w), i) = machinesOp(idx);
                                    %wrongOps(w) = machinesOp(randi([1 totalMach],1,1));
                                end;

                            end;

                            % CONROLE ANTIESTAGNACAO - Verificar se ja faz parte do conjunto solucao
                            idxRep = find(ismember(x, Sol, 'rows'));
                            while ~isempty(idxRep); % Enquanto as solucoes geradas estiverem no conjunto Sol

                                countRep = length(idxRep); % total de solucoes repetidas

                                % Para cada solucao repetida, atribuir novo valor de nivel para um
                                % operacao escolhida aleatoriamente
                                for c=1:countRep;
                                    % Selecionar aleatoriamento uma operacao da nuvem
                                    randOp = randi([1 n],1,1);

                                    % Atribuir novas Maquinas factiveis para a operacao i, na ordem de melhor >> pior, 
                                    [machines, priorities] = MachinesFeasible(randOp, 1, Tij(randOp, :), Mij, discardMachines);
                                    x(idxRep(c), randOp) = priorities;
                                end;

                                % Validar repeticao novamente
                                idxRep = find(ismember(x, Sol, 'rows'));

                            end;
                            
                            % Gerando (convertendo) particulas de operacao
                            P = x;
                            X = ParticleOperation(x,Mij);  

                            % RICARDO APPROACH !!!
                            fBest = Inf;
                            fWorst = 0;%max(pBestCost);
                            fX = 0;%round(sum(pBestCost)/length(pBestCost));     
                          % Avaliar particulas
                          for i=1:swarmSize;

                            % Simulated Annealing (Avaliacao da particula)
                            [M(i,:), makespan, X(i, :), ~] = SA(X(i, :), @Scheduler, @Fitness, @Neighbor);

                            % FITNESS    
                            if(makespan < pBestCost(i));
                                % Melhor local
                                pBestCost(i) = makespan;
                                pBestX(i, :) = X(i, :);
                                pBestM(i, :) = M(i, :);
                            end;
                                                        
                            % AIW-APPROACH
                            swarmCost(i) = makespan;

                          end;
                                                    
                          % Melhor global (inicial)
                          [gBestCost, idx] = min(pBestCost);
                          gBestX = pBestX(idx, :);
                          gBestM = pBestM(idx, :);
                          
                          % AIW-APPROACH
                          fBest = min(swarmCost);
                          fWorst = max(swarmCost);
                          fX = round(sum(swarmCost)/length(swarmCost)); 

                          histBest(iter) = gBestCost;

                          fprintf('Completed: %d/%d (gBest: %d)...\n', iter, nIter, gBestCost);

                        end;

%                         % Resultados (graficos)...
%                         fprintf('Plotando grafico..');
%                         figureHistory = figure();
%                         plot(histBest); 
%                         [makespan, schedule, scheduleOpsLabels] = Fitness(gBestM, Tij, Oij, m, n);
%                         figureBest = figure();
%                         Gantt(schedule, scheduleOpsLabels, makespan, m);
%                         fprintf('. Ok!\n');

                        timeExec = toc;
                        %disp(timeExec);

                        %% !!!!! Iteracoes de teste - gerando dados do relatorio !!!!!

                           % Salvar figuras...
                           folderResults = sprintf('Results/%s/Iter_%.0f-Swarm_%.0f-wMin_%.2f-wMax_%.2f-c1_%.2f-c2_%.2f/', dataset, nIter, swarmSize, wMin, wMax, c1, c2);
                           mkdir(folderResults);
                           %date_str = tst;%datetime('now','TimeZone','local','Format','dd.MM.yy_HH.mm.ss');
                           figureHistory = figure();
                           plot(histBest); 
                           saveas(figureHistory, sprintf('%s/%.0f-distHistory-COST_%.2f-.jpg', folderResults, tst, gBestCost)); % BestCost
                           [makespan, schedule, scheduleOpsLabels] = Fitness(gBestM, Tij, Oij, m, jobs);
                           Gantt(schedule, scheduleOpsLabels, makespan, m);
                           saveas(gcf, sprintf('%s/%.0f-best-COST_%.2f.jpg', folderResults, tst, gBestCost)); % History

                           % Salvar dados do teste...
                           dataSummary = [nIter swarmSize wMin wMax c1 c2 gBestCost timeExec];
                           dlmwrite(sprintf('Results/%s/Summary.csv', dataset), dataSummary, '-append', 'delimiter', ';');

                           % Variaveis
                           save(sprintf('%s/%.0f-gBestX.mat', folderResults, tst), 'gBestX');
                           save(sprintf('%s/%.0f-gBestM.mat', folderResults, tst), 'gBestM');
                           save(sprintf('%s/%.0f-histBest.mat', folderResults, tst), 'histBest');

                    end;
                    %% !!!!! Fim dos testes pro relatorio !!!!!
                    
%                 end;
%             end;
%         end;
%     end;
% 
% end;
%delete(gcp); 