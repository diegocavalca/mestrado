## Copyright (C) 2016 Diego
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} Fitness (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Diego <diego@diego-notebook>
## Created: 2016-10-25

function [valor] = Fitness (X, M, Times, Oij)

  % Auxiliares...
  Mj = zeros(1,8);
  Mm = zeros(1,8);

  opsJobs = cumsum(Oij);
  
  stageO = ones(1, 8);
  stageM = ones(1, 8);

  % Avaliar maquinas...
  for m=1:size(M,2);
  
    stageO = ones(1, 8); 
    
    ops = M(1,m){};
    
    % Operacoes atribuidas a cada maquina...
    for c=1:length(ops);
      
      % Indice da operacao da maquina
      opIdx = ops(c); 
      
      % Tempo da operacao na maquina...
      time = Times(opIdx, m);
      
      % Selecionar job
      job = find(opsJobs >= opIdx, 1, 'first'); 
      
      % Selecionar operacao
      if(job>1)
        op = opIdx-opsJobs(job-1); 
      else
        op = opIdx;        
      end;
      
      % Verificar se Oij eh factivel para Mi...
      if op==stageO(job);
        stageO(job) = stageO(job) + 1;
        disp(stageO);
      end;

      fprintf('Op(%d,%d) - M(%d): %d \n', round(job), round(op), round(m), round(time));
      
    end;
    
  end;

  
%%  schedule = zeros(length(M), 2*length(X));
%%  disp(schedule);
  
%%  % Avaliar operacoes...
%%  opIdx = 1;
%%  for job=1:length(Oij);
%%      for op=1:Oij(job);
%%        
%%        % Maquina atribuida p/ operacao...
%%        machine = X(opIdx);
%%        
%%        % Tempo...
%%        time = Times(opIdx, machine);
%%        fprintf('Op(%d,%d) - M(%d): %d \n', round(job), round(op), round(machine), round(time));
%%        
%%        schedule(machine, opIdx+1) =  schedule(machine, opIdx) + time;
%%        
%%        opIdx = opIdx + 1;
%%        
%%      end;            
%%  end;
%%  
%%  disp(schedule);

%%  for op=1:length(X);
%%    
%%    % Maquina para a operacao...    
%%    machine = X(op);
%%    % Custo para a operacao na maquina...
%%    time = Times(op, machine);
%%    disp(time);
%%    
%%  end;
  
  
  valor = 0;
  
endfunction
