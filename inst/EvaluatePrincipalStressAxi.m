## Copyright (C) 2023 Andreas Stahel
##
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{function file}{}[@var{sigma_1},@var{sigma_2}] = EvaluatePrincipalStressAxi(@var{sigma_x},@var{sigma_z},@var{tau_xz})
##
##   evaluate two principal stresses at the nodes
##
##parameters:
##@itemize
##@item @var{sigma_x} values of normal stress in x direction at the nodes
##@item @var{sigma_z} values of normal stress in z direction at the nodes
##@item @var{tau_xz}  values of shearing strain at the nodes
##@end itemize
##
##return values:
##@itemize
##@item @var{sigma_1} first principal stress at the nodes
##@item @var{sigma_2} second principal stress at the nodes
##@end itemize
##
## @c Will be cut out in ??? info file and replaced with the same
## @c references explicitly there, since references to core Octave
## @c functions are not automatically transformed from here to there.
## @c BEGIN_CUT_TEXINFO
## @seealso{EvaluateStress, EvaluateStrain, PlaneStress, PlaneStrain}
## @c END_CUT_TEXINFO
## @end deftypefn

## Author: Andreas Stahel <andreas.stahel@gmx.com>
## Created: 2022-10-23

function [sigma_1,sigma_2] = EvaluatePrincipalStressAxi(sigma_x,sigma_z,tau_xz)
  Discr   = sqrt((sigma_x-sigma_z).^2+4*tau_xz.^2)/2;
  Sum     = (sigma_x+sigma_z)/2;
  sigma_1 = Sum + Discr; sigma_2 = Sum - Discr;
endfunction
