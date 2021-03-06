function kde = kernelDensityEstimation(v,out,varargin)
% calculates a density function out of (weighted) unit vectors
%
% Input
%  v   - @vector3d
%  out - @vector3d
%
% Options
%  halfwidth - halfwidth of a kernel
%  kernel    - specifies a kernel
%  weights   - vector of weights, with same length as v
%

% parse some input 
if isempty(v)
  kde = zeros(size(out));
  return
end

hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',deLaValeePoussinKernel('halfwidth',hw));
c = get_option(varargin,'weights',ones(length(v),1));
c = c./sum(c);

% evaluate density
in_theta = fft_theta(v.theta);
in_rho   = fft_rho(v.rho);
out_theta= fft_theta(out.theta);
out_rho  = fft_rho(out.rho);

gh = [in_rho(:),in_theta(:)].';
r = [out_rho(:),out_theta(:)].';
	
% extract legendre coefficents
Al = psi.A;
if check_option(varargin,'antipodal') || v.antipodal || ...
    out.antipodal
  Al(2:2:end) = 0;
end
bw = get_option(varargin,'bandwidth',length(Al));
Al = Al(1:min(bw,length(Al)));
  
kde = call_extern('odf2pf','EXTERN',gh,r,c,Al);

