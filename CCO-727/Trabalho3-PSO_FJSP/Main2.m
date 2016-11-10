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
nIter = 30;

global swarmSize;
swarmSize = 30;

global wMax;
wMax = 1.2;

global wMin;
wMin = 0.4;

global c1;
c1 = 2;

global c2;
c2 = 1.5;

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
X = ones(swarmSize, n);
M = X;
P = X;
%f = V;

% ROTEAMENTO - Gerar populacao do enxame (roteamentos)
for i=1:n;
    
    % Maquinas factiveis na ordem de melhor >> pior, 
    [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij, 4);

    X(:, i) = machines;
    P(:, i) = priorities;
    
end;

% Variaveis objetivo
pBestX = zeros(swarmSize, n);
pBestM = pBestX;
pBestCost = Inf(1, swarmSize);
gBestX = zeros(1, n);
gBestM = gBestX;
gBestCost = Inf;

% AVALIACAO INICIAL dos individuos (roteamentos)
for i=1:swarmSize;
   
    % Simulated Annealing (Avaliacao da particula)
    [M, makespan, X(i, :)] = SA(X(i, :), @Scheduler, @Fitness, @Neighbor);

    % FITNESS
    pBestCost(i) = makespan;
    pBestX(i, :) = X(i, :);
    %pBestM(i, :) = M(i, :);
  
%   % Individuo (Roteamento)
%   x = X(i, :);
%   
%   % SEQUENCIAMENTO a partir do roteamento R
%   m_aux = Scheduler(R, m); 
%   
%   % FITNESS
%   %[makespan, ~, ~] = Fitness(m, Tij, Oij, m, n);
%   pBestCost(i) = makespan;
%   pBestX(i, :) = x;
%   pBestM(i, :) = m_aux;

end;

% Melhor global (inicial)
[gBestCost, idx] = min(pBestCost);
gBestX = pBestX(idx, :);
gBestM = pBestM(idx, :);

% PASSO 3
nIter = 5;
fprintf('Aplicando PSO... \n');
for iter=1:nIter;
  
  % Movimento da nuvem...
  w = wMax - ( (wMax - wMin)/nIter ) * iter;
  r1 = rand(swarmSize, 1);
  r2 = rand(swarmSize, 1);
  
  % Velocidade
  v = w*v + c1 * bsxfun(@times, r1, pBestX - X) + c2 * bsxfun(@times, r2, (bsxfun(@minus, gBestX, X)));
  
  % Posicao
  X = round(X + v);
  
  % Validar vMin e vMax
  X(X < 1) = 1;
  X(X > m) = m;
  
  % Ajustar operacoes que n possuem maquinas factiveis...
  for i=1:n;
      
    % Maquinas factiveis na ordem de melhor >> pior, 
    fMach = find(Tij(i, :));% Maquinas factives para operacao Oij (tempo > 0)
    machinesOp = Mij(i, ismember(Mij(i, :), fMach));% Maquinas factiveis na ordem de melhor >> pior
    machinesOp = machinesOp(1:length(machinesOp)-4);
    totalMach = length(machinesOp);

    % Operacoes que n possuem maquinas factiveis...
    wrongOps = find(~ismember(X(:,i),Tij(i,:)));
    for w=1:length(wrongOps)
        % Atribuindo uma maquina (rand) factivel para a operacao em questao
        X(wrongOps(w), i) = machinesOp(randi([1 totalMach],1,1));
        %wrongOps(w) = machinesOp(randi([1 totalMach],1,1));
    end;
    
  end;
  
  % Avaliar particulas
  for i=1:swarmSize;
      
    % Simulated Annealing (Avaliacao da particula)
    [M, makespan, X(i, :)] = SA(X(i, :), @Scheduler, @Fitness, @Neighbor);

    % FITNESS    
    if(makespan < pBestCost(i));
        pBestCost(i) = makespan;
        pBestX(i, :) = X(i, :);
        disp(makespan);
        %pBestM(i, :) = M(i, :);
    end;
      
  end;
  
  % Melhor global
  [gBestCost, idx] = min(pBestCost);
  gBestX = pBestX(idx, :);
  %gBestM = pBestM(idx, :);

  fprintf('Completed: %d/%d (gBest: %d)...\n', iter, nIter, gBestCost);
  
end;

% Plotando gBest
fprintf('Plotando grafico..');
[makespan, schedule, scheduleOpsLabels] = Fitness(Scheduler(gBestX,m), Tij, Oij, m, n);
Gantt(schedule, scheduleOpsLabels, makespan, m);
fprintf('. Ok!\n');