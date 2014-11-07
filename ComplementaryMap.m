%%  COMPLEMENTARYMAP    Computes the complementary map of a superoperator
%   This function has one required argument:
%     PHI: a superoperator
%
%   PHIC = ComplementaryMap(PHI) is the complementary map of PHI (in the
%   sense that it describes the information sent by PHI to the
%   environment).
%
%   This function has one optional input argument:
%     DIM (default has input and output of equal dimension)
%
%   PHID = ComplementaryMap(PHI,DIM) is the same as above, where DIM is a
%   1-by-2 vector containing the input and output dimensions of PHI, in
%   that order (equivalently, these are the dimensions of the first and
%   second subsystems of the Choi matrix PHI, in that order). If the input
%   or output space is not square, then DIM's first row should contain the
%   input and output row dimensions, and its second row should contain its
%   input and output column dimensions. DIM is required if and only if PHI
%   has unequal input and output dimensions and is provided as a Choi
%   matrix.
%
%   URL: http://www.qetlab.com/ComplementaryMap

%   requires: ApplyMap.m, ChoiMatrix.m, iden.m, IsCP.m, IsHermPreserving.m,
%             IsPSD.m, KrausOperators.m, MaxEntangled.m, opt_args.m,
%             PermuteSystems.m, Swap.m
%
%   author: Nathaniel Johnston (nathaniel@njohnston.ca)
%   package: QETLAB
%   version: 0.50
%   last updated: January 22, 2013

function PhiC = ComplementaryMap(Phi,varargin)

isc = iscell(Phi);
if(~isc) % don't alter the Kraus operators -- will change the returned complementary map!
    Phi = KrausOperators(Phi,varargin{:});
end

% The complementary map is obtained by placing all of the first rows of
% Kraus operators of PHI into the first of PHIC's Kraus operators, all of
% the second rows of the Kraus operators of PHI into the second of PHIC's
% Kraus operators, and so on.
PhiC = mat2cell(Swap(cell2mat(Phi),[size(Phi,1),size(Phi{1},1)],[1,2],1),size(Phi,1)*ones(1,size(Phi{1},1)),size(Phi{1},2)*ones(1,size(Phi,2)));

if(~isc) % return a Choi matrix if that was the input
    PhiC = ChoiMatrix(PhiC);
end