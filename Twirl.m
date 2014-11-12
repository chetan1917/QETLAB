%%  TWIRL    Twirls a bipartite or multipartite operator
%   This function has one required argument:
%     X: a matrix
%
%   TX = Twirl(X) is the Werner twirl of the bipartite operator X.
%
%   This function has two optional arguments:
%     TYPE (default 'werner')
%     P (default 2)
%
%   TX = Twirl(X,TYPE,P) is the twirl of the P-partite operator X. TYPE
%   must be one of 'werner', 'isotropic', or 'real'. A 'werner' twirl is a
%   twirl over all complex unitaries of the form U^{\otimes P}, an
%   'isotropic' twirl is a twirl over all complex unitaries of the form U
%   \otimes conj(U), and a 'real' twirl is a twirl over all real orthogonal
%   matrices of the form O^{\otimes P}. Note that P = 2 is required if
%   TYPE = 'isotropic'.
%
%   URL: http://www.qetlab.com/Twirl

%   requires: AntisymmetricProjection.m, BrauerStates.m, iden.m,
%             MaxEntangled.m,, opt_args.m, perm_sign.m,
%             perfect_matchings.m, PermutationOperator.m, PermuteSystems.m,
%             sporth.m, SymmetricProjection.m, Tensor.m
%   author: Nathaniel Johnston (nathaniel@njohnston.ca)
%   package: QETLAB
%   version: 0.51
%   last updated: November 12, 2014

function TX = Twirl(X,varargin)

    lX = length(X);

    % set optional argument defaults: type='werner', p=2
    [type,p] = opt_args({ 'werner', 2 },varargin{:});

    if(strcmpi(type,'isotropic') == 1 && p > 2)
        error('Twirl:InvalidP','Values of P > 2 are not supported for isotropic twirling.');
    end

    d = round(lX^(1/p));

    % The Werner twirl is slightly complicated because I'm not aware of a
    % general formula for the multipartite case. In the bipartite case it's a
    % simple linear combination of the symmetric and antisymmetric projections,
    % but in the multipartite case you have to do more work to figure out what
    % the coefficients of the permutation operators are.
    if(strcmpi(type,'werner'))
        % First, construct the operators that Werner twirling projects down
        % onto (i.e., the p! permutation operators).
        p_fac = factorial(p);
        per = perms(1:p);
        
        for j = p_fac:-1:1
            ProjOps{j} = PermutationOperator(d*ones(1,p),per(j,:),0,1)';
        end

        % Now project down.
        TX = ProjectOntoOperators(X,ProjOps);

    % Computing the isotropic twirl of a bipartite state is easy: we have an
    % explicit formula.
    elseif(strcmpi(type,'isotropic'))
        v = MaxEntangled(d,1);
        a = v'*X*v;

        TX = a*v*v' + (trace(X)-a)*(speye(d^2)-v*v')/(d^2-1);

    % Computing the real orthogonal twirl of a bipartite state is similarly
    % easy: we could just plug into a formula. The multipartite case is a bit
    % messier, but we just implement this more general procedure for all p.
    elseif(strcmpi(type,'real'))
        % First, construct the operators that real orthogonal twirling
        % projects down onto.
        B = BrauerStates(d,p);
        szBlocal = sqrt(size(B,1));
        
        for j = size(B,2):-1:1
            ProjOps{j} = reshape(B(:,j),szBlocal,szBlocal);
        end

        % Now project down.
        TX = ProjectOntoOperators(X,ProjOps);

    % If the user tried to do a twirl that we don't understand, get cranky.
    else
        error('Twirl:InvalidType','TYPE must be one of ''werner'', ''isotropic'', or ''real''.');
    end
end

% This function projects the operator X onto the space spanned by the (not
% necessarily orthogonal) operators in the cell ProjOps.
function TX = ProjectOntoOperators(X,ProjOps)
    numops = length(ProjOps);
    lX = length(X);
    
    coeff_matrix = zeros(numops);
    tr_vec = zeros(numops,1);

    % Start by creating a coefficient matrix.
    for j = 1:numops
        for k = 1:numops
            coeff_matrix(j,k) = trace(ProjOps{j}'*ProjOps{k});
        end
        tr_vec(j) = trace(ProjOps{j}'*X);
    end

    % Now solve the system of equations.
    coeffs = pinv(coeff_matrix)*tr_vec; % more stable than using coeff_matrix\tr_vec

    % Finally, just sum everything up.
    TX = sparse(lX,lX);
    for j = 1:numops
        TX = TX + coeffs(j)*ProjOps{j};
    end
end