% %% Iteracoes de teste - gerando dados do relatorio
% for tst = 1:10;
% %% Fim dos testes pro relatorio
    
tic;

% Importando dados do benchmark
global Tij;
global Oij;
Tij = importdata('benchmarks/tempos8x8.txt'); % Tempos das operacoes
Oij = importdata('benchmarks/op8x8.txt'); % Operacoes por job

% ORGANIZANDO MAQUINAS - Melhores tempos tem prioridade 1, maior tem
% prioridade M, sendo M > 0, senao a maquina M nao eh factivel para Oij
global Mij;
Mij = MachinesPrior(Tij);

% Variaveis do problema
global n;
global m;
[n,m] = size(Tij);

% Configuracoes PSO
%swarmSize = 15; % tamanho da nuvem...
%nIter = 10; % Iteracoes do algoritmo...
%c1 = 1.4944;
%c2 = 1.4944;
%w = 0.9;
nIter = 30; %15;
swarmSize = 30; %100;
wMax = 1.5;
wMin = 0.4;
c1 = 2;
c2 = c1;

% Configuracoes SA
global t0;
t0 = 3;

global tEnd;
tEnd = 0.01;

global B;
B = 0.9;

v = zeros(swarmSize, n);
vMin = 1;
vMax = m;

% Nuvem (populacao) e solucao inicial
X = zeros(swarmSize, n);
M = cell(swarmSize, m);
P = X;
O = X;
%f = V;

% Variaveis objetivo
% Local
pBestX = zeros(swarmSize, n);
pBestM = M;
pBestCost = Inf(1, swarmSize);
% Global
gBestX = zeros(1, n);
gBestM = cell(1,m);
gBestCost = Inf;

% Variaveis adicionais
discardMachines = 4;
Sol = zeros(1, n); % Controle de estagnacao
histBest = zeros(1, swarmSize);

% ROTEAMENTO - Gerar populacao do enxame (roteamentos)
for i=1:n;
    
    % Maquinas factiveis na ordem de melhor >> pior, 
    [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, discardMachines);
    
%     % Maquinas factives para operacao Oij (tempo > 0)
%     fMach = find(Tij);
%     
%     % Maquinas factiveis na ordem de melhor >> pior
%     machinesOp = Mij(i, ismember(Mij(i, :), fMach));
%     
%     % Estocastico = eliminar ultima maquina (mais lenta pra Oij) e atribuir
%     % maquina de maneira que todas tenham mesma probabilidade
%     machinesOp = machinesOp(1:2);
%     
%     probs = ones(1, length(machinesOp))*1/length(machinesOp);
%     
%     % Maquinas factiveis resultantes
%     machines = randsample(machinesOp, swarmSize, true, probs);
%     % Indices de prioridade das maquinas factives
%     [~, priorities] = ismember(machines, Mij(op, :));

    X(:, i) = machines;
    P(:, i) = priorities;
    
end;

% AVALIACAO INICIAL dos individuos (roteamentos)
for i=1:swarmSize;
   
    % Simulated Annealing (Avaliacao da particula)
    [M(i,:), makespan, X(i, :), ~] = SA(X(i, :), @Scheduler, @Fitness, @Neighbor);

    % FITNESS
    pBestCost(i) = makespan;
    pBestX(i, :) = X(i, :);
    pBestM(i, :) = M(i, :);
    
    % Solucoes ja encontradas
    P(i, :) = ParticlePosition(X(i, :), Mij);
%     if i==1;
%         Sol = P(i,:);
%     else
%         Sol = [Sol; P(i,: )];
%     end;
   
  
%     % Individuo (Roteamento)
%     R = X(i, :);
% 
%     % SEQUENCIAMENTO a partir do roteamento R
%     m_aux = Scheduler(R, m); 
% 
%     % FITNESS
%     [makespan, ~, ~] = Fitness(m_aux, Tij, Oij, m, n);
%     pBestCost(i) = makespan;
%     pBestX(i, :) = R;
%     %pBestM(i, :) = m_aux;

end;

% Melhor global (inicial)
[gBestCost, idx] = min(pBestCost);
gBestX = pBestX(idx, :);
gBestM = pBestM(idx, :);

% PASSO 3
%nIter = 5;
fprintf('Aplicando PSO... \n');
for iter=1:nIter;
  
  % Insere particulas no registro de solucoes
  Sol = [Sol; P];
  
  % Movimento da nuvem (Exploracao Global)...
  w = wMax - ( (wMax - wMin)/nIter ) * iter;
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

      % Maquinas factives (4 melhores)
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
  
%   % Validar/Ajustar operacoes que n possuem maquinas factiveis...
%   for i=1:n;
%       
%     % Maquinas factiveis na ordem de melhor >> pior, 
%     fMach = find(Tij(i, :));% Maquinas factives para operacao Oij (tempo > 0)
%     machinesOp = Mij(i, ismember(Mij(i, :), fMach));% Maquinas factiveis na ordem de melhor >> pior
%     machinesOp = machinesOp(1:length(machinesOp)-4);
%     totalMach = length(machinesOp);
% 
%     % Operacoes que n possuem maquinas factiveis...
%     wrongOps = find(~ismember(X(:,i),Tij(i,:)));
%     for w=1:length(wrongOps)
%         % Atribuindo uma maquina (rand) factivel para a operacao em questao
%         X(wrongOps(w), i) = machinesOp(randi([1 totalMach],1,1));
%         %wrongOps(w) = machinesOp(randi([1 totalMach],1,1));
%     end;
%     
%   end;

    % Verificar se ja faz parte do conjunto solucao (ANTIESTAGNACAO)
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
%     if sum(ismember(x, Sol, 'rows'))>0;
%         
% %         % Selecionar aleatoriamento uma operacao da nuvem
% %         i = randi([1 n],1,1);
% %         
% %         % Atribuir novas Maquinas factiveis para a operacao i, na ordem de melhor >> pior, 
% %         [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, discardMachines);
% %         x(:,i) = priorities;
%         
%         % Caso encontre, trocar estocasticamente o valor de uma operacao
%         % selecionada randomicamente para cada particula em x
%         
%         disp('Antiestag!');
%         
%         for c=1:swarmSize;
%             % Selecionar aleatoriamento uma operacao da nuvem
%             randOp = randi([1 n],1,1);
% 
%             % Atribuir novas Maquinas factiveis para a operacao i, na ordem de melhor >> pior, 
%             [machines, priorities] = MachinesFeasible(randOp, 1, Tij(randOp, :), Mij, discardMachines);
%             x(:,randOp) = priorities;
%         end;
%         
%         %         totalMach = length(unique(machines));
%         %         % Operacoes que n possuem maquinas factiveis...
%         %         wrongOps = find(~ismember(X(:,i),Tij(i,:)));
%         %         for w=1:length(wrongOps)
%         %             % Atribuindo uma maquina (rand) factivel para a operacao em questao
%         %             X(wrongOps(w), i) = machinesOp(randi([1 totalMach],1,1));
%         %             %wrongOps(w) = machinesOp(randi([1 totalMach],1,1));
%         %         end;
%     end;
    
    % Gerando (convertendo) particulas de operacao
    P = x;
    X = ParticleOperation(x,Mij);  
  
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
    if(makespan < gBestCost);
        % Melhor global
        gBestCost = makespan;
        gBestX = X(i, :);
        gBestM = M(i, :);
    end;
    
    %Sol = [Sol; P(i,: )];
    
  end;
  
  histBest(iter) = gBestCost;
  
  fprintf('Completed: %d/%d (gBest: %d)...\n', iter, nIter, gBestCost);
  
end;

% Resultados (graficos)...
fprintf('Plotando grafico..');
figureHistory = figure;
plot(histBest);
%rte = gBest([1:rows 1]);
%plot(rte',rte','r.-'); % Caminho
%plot(eil51(rte,2),eil51(rte,3),'r.-'); % Pontos (cidades)   
[makespan, schedule, scheduleOpsLabels] = Fitness(gBestM, Tij, Oij, m, n);
Gantt(schedule, scheduleOpsLabels, makespan, m);
fprintf('. Ok!\n');

timeExec = toc;
disp(timeExec);

%     %% !!!!! Iteracoes de teste - gerando dados do relatorio !!!!!
% 
%        % Salvar figuras...
%        folderResults = sprintf('Results/Iter_%d-Swarm_%d-Cpr_%.2f-W_%.2f-C_%.2f/', numIter, swarmSize, cPr, w, beta);
%        mkdir(folderResults);
%        DateString = datestr(datetime('now'));
%        date = str2num(datestr(now,'ddmm'));
%        hour = str2num(datestr(now,'HHMM'));
%        datestr = datestr(now,'ddmm-HHMMSS');
%        saveas(figureBestRoute, sprintf('%s/bestRoute-COST_%.2f-%s.jpg', folderResults, gBestScore, datestr)); % BestRoute
%        saveas(figureHistory, sprintf('%s/distHistory-COST_%.2f-%s.jpg', folderResults, gBestScore, datestr)); % History
%        
%        % Salvar dados do teste...
%        dataSummary = [date hour numIter swarmSize w alpha beta cPr gBestScore timeExec];
%        dlmwrite('Results/Summary.csv', dataSummary, '-append', 'delimiter', ';');
%     
%        % Variaveis
%        save(sprintf('%s/gBest-%s.mat', folderResults, datestr), 'gBest');
%        save(sprintf('%s/histBest-%s.mat', folderResults, datestr), 'histBest');
%         
% end;
%     %% !!!!! Fim dos testes pro relatorio !!!!!