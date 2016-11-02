function [ p ] = ParticlePosition( R, Mij )
    % Recebe o roteamento (sequencia de maquinas que processam Oij)
    % e retorna o indice de prioridade referente a cada maquina em questao
    % R = particula original (maquinas por Oij)
    % Mij = matriz de prioridades de maquinas (colunas) para cada Oij (row)
    n = size(R, 2);
    p = zeros(1, n);
    for i=1:n;
        p(i) = find( ismember( Mij(i,:), R(i) ) );
    end;
end

