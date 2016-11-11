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
global nIter;
nIter = 15;

global swarmSize;
swarmSize = 30;

global wMax;
wMax = 1.2;

global wMin;
wMin = 0.4;

global c1;
c1 = 2;

global c2;
c2 = c1;

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

Sol = zeros(1, n);

% ROTEAMENTO - Gerar populacao do enxame (roteamentos)
for i=1:n;
    
    % Maquinas factiveis na ordem de melhor >> pior, 
    [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, 4);

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
    if i==1;
        Sol = P(i,:);
    else
        Sol = [Sol; P(i,: )];
    end;
   
  
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
  
  % Movimento da nuvem (Exploracao Global)...
  w = wMax - ( (wMax - wMin)/nIter ) * iter;
  r1 = rand(swarmSize, 1);
  r2 = rand(swarmSize, 1);
  
  x = P;
  pBest = ParticlePosition(pBestX, Mij);
  gBest = ParticlePosition(gBestX, Mij);
  
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
      machinesOp = machinesOp(1:length(machinesOp)-4);
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
    if sum(ismember(x, Sol, 'rows'))>0;
        % Selecionar aleatoriamento uma operacao da nuvem
        i = randi([1 n],1,1);
        
        % Atribuir novas Maquinas factiveis para a operacao i, na ordem de melhor >> pior, 
        [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, 4);
        x(:,i) = priorities;
        
        %         totalMach = length(unique(machines));
        %         % Operacoes que n possuem maquinas factiveis...
        %         wrongOps = find(~ismember(X(:,i),Tij(i,:)));
        %         for w=1:length(wrongOps)
        %             % Atribuindo uma maquina (rand) factivel para a operacao em questao
        %             X(wrongOps(w), i) = machinesOp(randi([1 totalMach],1,1));
        %             %wrongOps(w) = machinesOp(randi([1 totalMach],1,1));
        %         end;
    end;
    
    % Gerando particulas de operacao
    P = x;
    Sol = [Sol; P];
    
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
        [gBestCost, idx] = min(pBestCost);
        gBestX = pBestX(idx, :);
        gBestM = pBestM(idx, :);
    end;
    
    Sol = [Sol; P(i,: )];
    
  end;
  
  fprintf('Completed: %d/%d (gBest: %d)...\n', iter, nIter, gBestCost);
  
end;

% Plotando gBest
fprintf('Plotando grafico..');
[makespan, schedule, scheduleOpsLabels] = Fitness(gBestM, Tij, Oij, m, n);
Gantt(schedule, scheduleOpsLabels, makespan, m);
fprintf('. Ok!\n');

timeExec = toc;