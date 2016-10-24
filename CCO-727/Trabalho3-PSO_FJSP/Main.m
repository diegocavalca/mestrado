% Importando dados do benchmark
Tij = importdata('benchmarks/tempos8x8.txt'); % Tempos das operacoes
Oij = importdata('benchmarks/op8x8.txt'); % Operacoes por job

% Vari�veis do problema
[n,m] = size(Tij);

% Configuracoes PSO
swarmSize = 15; % tamanho da nuvem...

% Nuvem (populacao) e solucao inicial
X = ones(swarmSize, n);

% ROTEAMENTO - Define as opera��es para quais m�quinas (respeitando)
for i=1:n;
    % Maquinas factives para Oij
    fMach = find(Tij(i,:));
    % Atribuir m�quinas para cada Oij (aleatorio)
    X(:,i) = fMach(randi(numel(fMach), swarmSize, 1));
end;

% SEQUENCIAMENTO - operacoes das m�quinas pra cada solu��o (linha de X)...
M = cell(swarmSize, m);
for i=1:swarmSize;
    for mach=1:m;
        % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
        fOper = find( X(i,:) == mach );
        M{i,mach} = fOper;
    end;    
end;

% Aplicar busca local para definir programa��o (sequencia de operacoes na
% m�quina)

% Calcular aptid�o sobre a programa��o resultante
