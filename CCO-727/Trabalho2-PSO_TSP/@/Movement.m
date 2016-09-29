% ## Copyright (C) 2016 Diego Cavalca
% ## 
% ## This program is free software; you can redistribute it and/or modify it
% ## under the terms of the GNU General Public License as published by
% ## the Free Software Foundation; either version 3 of the License, or
% ## (at your option) any later version.
% ## 
% ## This program is distributed in the hope that it will be useful,
% ## but WITHOUT ANY WARRANTY; without even the implied warranty of
% ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% ## GNU General Public License for more details.
% ## 
% ## You should have received a copy of the GNU General Public License
% ## along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
% ## -*- texinfo -*- 
% ## @deftypefn {Function File} {@var{retval} =} SwapOperators (@var{input1}, @var{input2})
% ##
% ## @seealso{}
% ## @end deftypefn
% 
% ## Author: Diego Cavalca <diego.cavalca@dc.ufscar.br>
% ## Created: 2016-09-27

function Xi = Movement (X, V)
    %disp(length(V));
    for i=1:size(V,1);%length(V); 
        vel = V(i,:); %V(v,:);
        X([vel(1) vel(2)]) = X([vel(2) vel(1)]); % Operacoes de troca...
        %if( X(1) ~= X(size(X,2)) ); X(size(X,2)) = X(1); end;              
    end;
    
    Xi = X;

end
