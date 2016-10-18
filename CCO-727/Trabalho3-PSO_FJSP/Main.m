% Importando dados do benchmark
tempo_jobs = importdata('benchmarks/tempos8x8.txt');
operacoes_jobs = importdata('benchmarks/op8x8.txt');

% Vari�veis do problema
[n,m] = size(tempo_jobs);

particulas = 15; % tamanho da nuvem...

% Nuvem (populacao) e solucao inicial
X = ones(particulas, n);

% Roteamento - Define as opera��es para quais m�quinas (respeitando)
for i=1:n;
    % Maquinas factives para Oi,j
    fMach = find(tempo_jobs(i,:));
    % Atribuir m�quinas para cada Oi,j (aleatorio)
    X(:,i) = fMach(randi(numel(fMach), particulas, 1));
end;

% Planejamento - operacoes das m�quinas pra cada solu��o (linha de X)...
M = cell(size(X));
for i=1:particulas;
    for j=1:m;
        % Maquinas factives para Oi,j
        fOper = find( X(i,:) == m );
        
    end;    
end;

% Aplicar busca local para definir programa��o (sequencia de operacoes na
% m�quina)

% Calcular aptid�o sobre a programa��o resultante