% Importando dados do benchmark
Tij = importdata('benchmarks/tempos8x8.txt'); % Tempos das operacoes
Oij = importdata('benchmarks/op8x8.txt'); % Operacoes por job

% Variaveis do problema
[n,m] = size(Tij);

% Configuracoes PSO
%swarmSize = 15; % tamanho da nuvem...
%nIter = 10; % Iteracoes do algoritmo...
%c1 = 1.4944;
%c2 = 1.4944;
%w = 0.9;
nIter = 50;
swarmSize = 100;
wMax = 1.2;
wMin = 0.4;
c1 = 2;
c2 = c1;
t0 = 3;
tEnd = 0.01;
B = 0.9;
v = zeros(1, n);
vMin = 1;
vMax = m;

% Nuvem (populacao) e solucao inicial
X = ones(swarmSize, n);
P = X;
%f = V;

% ORGANIZANDO MAQUINAS - Melhores tempos tem prioridade 1, maior tem
% prioridade M, sendo M > 0, senao a maquina M nao eh factivel para Oij
Mij = MachinesPrior(Tij);

% ROTEAMENTO - Gerar populacao do enxame (roteamentos)
for i=1:n;
    
    % Maquinas factiveis na ordem de melhor >> pior, 
    %selecionadas de modo estocastico (detalhes na funcao
    [machines, priorities] = MachinesFeasible(i, swarmSize, Tij(i, :), Mij);
    X(:, i) = machines;
    P(:, i) = priorities;
    
end;

% Variaveis objetivo
pBest = zeros(swarmSize, n);
pBestCost = Inf(1, swarmSize);
gBest = zeros(1, n);
gBestCost = Inf;

% AVALIACAO INICIAL dos individuos (roteamentos)
for i=1:swarmSize;
  
  % Inidividuo (Roteamento)
  R = X(i, :);
  
  % SEQUENCIAMENTO a partir do roteamento R
  M = Scheduler(R, m); 
  
  % FITNESS
  [makespan, schedule, scheduleOpsLabels] = Fitness(M, Tij, Oij, m, n);
  pBestCost(i) = makespan;
  pBest(i, :) = R;

end;

% Melhor global (inicial)
[gBestCost, idx] = min(pBestCost);
gBest = pBest(idx, :);

% % % % PASSO 3
% % % for iter=1:nIter;
% % % 
% % %   % Atualizar particulas...
% % %   for i=2:swarmSize;
% % %   
% % %     % Fator de inercia
% % %     w = wMax - ( (wMax - wMin)/nIter ) * iter;
% % % 
% % %     r1 = rand(swarmSize, 1);
% % %     r2 = rand(swarmSize, 1);
% % %     %v = w*v + c1 * bsxfun(@times, r1, melhores_locais - x) + ...
% % %     %  c2 * bsxfun(@times, r2, (bsxfun(@minus, melhores_globais, x)));
% % %     x = ParticlePosition(X(i,:), Mij);
% % %     
% % %     % Velocidade
% % %     v = w*v + c1*rand()*(pBest(i,:) - x) + c2*rand()*(gBest - x);
% % %     
% % %     % Posicao
% % %     x_aux = round(x + v);
% % %     x_aux(x_aux < vMin) = vMin;
% % %     x_aux(x_aux > vMax) = vMax;
% % %     
% % %     % Avaliacao...  
% % %     M = Scheduler(x_aux, m); % SEQUENCIAMENTO a partir do roteamento R
% % %     [makespan, ~, ~] = Fitness(M, Tij, Oij, m, n);
% % %     if(pBestCost(i)>makespan)
% % %         pBestCost(i)=makespan;
% % %         pBest(i,:)=x_aux;
% % %     end
% % %     if(gBestCost>makespan)
% % %         gBestCost=makespan;
% % %         gBest=x_aux;
% % %     end;
% % % 
% % %   end;
% % %   
% % % end;


% SEQUENCIAMENTO - (inicial) operacoes das maquinas pra cada solucao (linha de X)...
%M = Scheduler(X(1,:), m);
% Avaliacao da solucao inicial
%[makespan, schedule, scheduleOpsLabels] = Fitness(M, Tij, Oij, m, n);
%Gantt(schedule, scheduleOpsLabels, makespan, m);

% Plotando gBest
[makespan, schedule, scheduleOpsLabels] = Fitness(Scheduler(gBest, m), Tij, Oij, m, n);
Gantt(schedule, scheduleOpsLabels, makespan, m);


%M = cell(swarmSize, m);
%for i=1:swarmSize;
%    for mach=1:m;
%        % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
%        fOper = find( X(i,:) == mach );
%        M{i,mach} = fOper;
%    end;    
%end;

% FITNESS - 


% Aplicar busca local para definir programacao (sequencia de operacoes na
% maquina)

% Calcular aptidao sobre a programacao resultante
