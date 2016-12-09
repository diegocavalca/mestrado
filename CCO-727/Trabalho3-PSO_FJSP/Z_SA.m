%Este fitness do PSO na verdade » outro algoritmo (SA), trabalhando para
%converter os encodes baseado em opera¡?es, para um encode baseado em
%m∑quina e assim processar seus tempos no fitnessSA (que na verdade » a aptid?o de todo o sistema)
function [minbestSolCost, bestSchedule] = SA2(S, tempo_jobs, m, n, iterationsAtTemp, sT, ...
                               alpha, fitnessSA, ...
                               gerar_vizinho,alternativa_produtos,n_iteracoesSA,leveis,Tend)
    global jobs;
  %inicializa os custos, final e vetor de custos                  
  costsEnd = 0;
  costs = zeros(1,(n_iteracoesSA*iterationsAtTemp));
  %roteiro = [2 5 6     3 4 7 5     7 4 1   2 6 3   1 7 6 7      3 8 2      3 8 4   1 2 8 3];

  %vari∑veis de controle do procedimento de cria¡?o de todas as permuta¡?es
  %possÃveis dos nÃveis
  opcoes = cell(1, m);
  total = 1;
  
  %o procedimento abaixo gera a partir de um roteiro de opera¡?es em nÃveis, todas os roteiros
  %possÃveis das combina¡?es destes nÃveis expressados em tempos, ou seja, se uma mesma opera¡?o
  %de nivel 1 possuir 2 m∑quinas com tempos iguais, teremos j∑ de antem?o 2
  %roteiros possÃveis se todas as outras opera¡?es possuirem nÃveis com
  %apenas 1 m∑quina
  for i=1:n
    opcoes{i} = find(S(i)==leveis(i,:));
    total = total * length(opcoes{i}) ; % 3
  end
    repeticoes = total; %3
    MS = zeros(total,n);
  for i=1:n 
    coluna = zeros(total,1);
    repeticoes = repeticoes/length(opcoes{i}); %1
    if total == repeticoes
      permutacoes = length(opcoes{i});
    else
      permutacoes = total/repeticoes; %3
    end
    for j=1:permutacoes
      intervalo_inicio = repeticoes*(j-1)+1;
      intervalo_fim = (repeticoes*(j-1))+repeticoes;
      coluna(intervalo_inicio:intervalo_fim,1) = opcoes{1,i}(mod(j-1,length(opcoes{i}))+1);
    end
    MS(:,i) = coluna;     
  end
  bestSolCost = zeros(total,1);  
  
  %para cada roteiro gerado » necess∑rio avaliar sua aptid?o
  for z=1:total 
      %transforma em um encode baseado em m∑quina
      k = cell(1, m);
      for i=1:m
        k{i} = find(MS(z,:)==i);
      end
      
      %j∑ atribui um melhor valor com o roteiro do jeito que est∑ de inÃcio
      bestSol = k;
      bestSolCost(z,1) = fitnessSA(k, tempo_jobs, alternativa_produtos, m, jobs);%fitnessSA(tempo_jobs, m, alternativa_produtos,k);
      %se o roteiro der deadlock (tiver errada a precendencia das
      %opera¡?es), for¡a gerar um novo sequenciamento
      while bestSolCost(z,1) == 0 
          k = gerar_vizinho(bestSol, m);
          bestSolCost(z,1) = fitnessSA(k, tempo_jobs, alternativa_produtos, m, jobs);
      end
      
      %variavel que ira permutar a sequencia¡?o do roteiro inicialmente
      acceptedSol = k;
      acceptedSolCost = bestSolCost(z,1);
      %temperatura do SA
      T = sT;
      
      
      %enquanto a temperatura for maior que a definida fa¡a
      while T > Tend
      %» necess∑rio repetir o procedimento x vezes na mesma temperatura para garantir a distin¡?o dos resultados
        for i=1:iterationsAtTemp
          %gera uma nova sequencia¡?o e j∑ avalia sua aptid?o
          newSol = gerar_vizinho(acceptedSol, m);
          newSolCost = fitnessSA(k, tempo_jobs, alternativa_produtos, m, jobs);
          %se der deadlock, for¡a uma nova sequencia¡?o
          while newSolCost == 0 
              newSol = gerar_vizinho(acceptedSol, m);
              newSolCost = fitnessSA(k, tempo_jobs, alternativa_produtos, m, jobs);       
          end
          %verifica se houve melhora, e mesmo se n?o houve, com uma
          %probabilidade a solu¡?o » atualizada
          deltaCost = newSolCost - acceptedSolCost;
          if deltaCost < 0
            acceptedSol = newSol;
            acceptedSolCost = newSolCost;
          else
            randVal = rand(1);
            p = exp(-1*deltaCost / T);
            if p > randVal
              acceptedSol = newSol;
              acceptedSolCost = newSolCost;
            end
          end

          %grava o valor no vetor de custos
          costsEnd = costsEnd + 1;
          costs(costsEnd) = acceptedSolCost;

          %Atualiza o melhor custo
          if acceptedSolCost < bestSolCost(z,1)
             bestSolCost(z,1) = acceptedSolCost;
          end
        end
        T = T * alpha; % resfriamento do SA
      end
  end
  [minbestSolCost, index] = min(bestSolCost);
  bestSchedule = MS(index,:);
end
