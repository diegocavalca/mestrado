## Copyright (C) 2016 Diego Cavalca
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
## @deftypefn {Function File} {@var{retval} =} SwapOperators (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Diego Cavalca <diego.cavalca@dc.ufscar.br>
## Created: 2016-09-27

function SS = SwapOperators (P1, P2, c)

    % Operadores de troca (gBest ou pBest) - Xt
    %if( X(i,:) ~= pBest(i,:) );
    SS = [];
    Paux = P1;
    x = P2;       
    sizeP = size(Paux,2);    
    parfor j=1:sizeP-1;
        % Elementos x em Paux
        idxP2 = find(x([1:sizeP])==Paux(j));
        % verificar se ja n faz parte - sum(ismember(SS,SO,'rows'))==0
        if( (j ~= idxP2) && (sum(ismember(SS,[j idxP2],'rows'))==0) );
            SO = [j idxP2];
            SS = [SS; SO]; % SO
            % Atualizar x
            x([j idxP2]) = x([idxP2 j]); 
            if( x(1) ~=x(size(Paux,2)) ); x(size(x,2)) = x(1); end;
        end;
    end;            
    % Memoria da Vizinhanca
    if(c>0 && c<1)
      SS = SS([1:ceil( c * size(SS,1))],:);                
    else
      SS = [];                 
    end;

endfunction
