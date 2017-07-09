function myPSL = ql2psl(im, res, sen, lat, grad)
%% Function to convert QL values to PSL values of an 2D matrix or image
% Convert Quantum Level (QL) pixel values from phosphorimage output to the
% Photo Stimulated Luminescence (PSL) Value, or the  quantified value in
% linear scale.
% 
% Conversion Formulae:
%
% $PSL = ({\frac{Res}{100}})^2({\frac{4000}{S}})({(10^{L(\frac{QL}{G} - \frac{1}{2})})}$
%
% $QL = \frac{({G})({log(\frac{(({5})({PSL})({S})}{(({2})({RES}^2)})}}{(({L})({log(10)})) + \frac{1}{2}}$
%
%
% Conversion Formula: 
% PSL = (Res/100)^2 x (4000/S) x (10^L(QL/G - 0.5))
% 
% Solved with symbolic expression 
% syms PSL QL RES S L G
% QL2PSL = PSL == (2*10^(L*(QL/G - 1/2))*RES^2)/(5*S))
%
% Alternatively, I can convert PSL2QL with: 
% PSL2QL = QL == G*(log((5*PSL*S)/(2*RES^2))/(L*log(10)) + 1/2)
% (Not sure why I'd want to yet, but it's here if I need it.)
% 
%  PSL = Photo Stimulated Luminescence
%  Res = Resolution in um
%  S   = Sensitivity
%  L   = Latitude, or dynamic range "above number" power of 10
%  QL  = Quantum Level, or log-transformed pixel value from .img file after scanning
%  G   = Gradation, or maximum pixel value based on bit-depth (8-bit [255] or 16-bit [65535])
% 
%
% Usage psl_value = ql2psl(ql);
% Input:
%      im   = 2D matrix or image containing unconverted pixel values (QL matrix)
%      res  = Resolution (Res)
%      sen = Sensitivity (S)
%      lat  = Latitude (L)
%      grad = Gradation (G)
%
% Output:
%      psl  = 2D matrix containing PSL-converted pixel values (PSL matrix)


%% For Debug Purposes: Test with default parameter values
% Comment out for regular use! 
% res = 200;
% sen = 10000;
% lat = 5;
% grad = 65535; % For sample 16-bit image
% grad8 = 255; % For sample 8-bit image
% myQL = [17271 50852 40946;...
%            40818 17461 3787;...
%            12514 38312 31545;...
%            23505 3632  2480;...
%            25503 23183 29187;] % Sample matrix with known PSL values

%% Solved using symbolic expression
ql = double(im);
myPSL = (2*10.^(lat*(ql/grad - 0.5))*res^2)/(5*sen);

% Convert back to QL if wanted
% myQL = grad * (log((5 * myPSL * sen) / (2 * res^2)) / (lat * log(10)) + 0.5;

%% Old and inefficient method (2x slower!)
% To simplify equation, make A = (Res/100)^2 x (4000/S) and B = QL/G - 0.5
% tic
% ql = im;
% A = ((res / 100)^2) * (4000 / sen);
% B = zeros(size(ql,1), size(ql,2));
% psl = zeros(size(ql,1), size(ql,2));
% 
% for i = 1:size(B,1)
%     B(i,:) = lat * (ql(i,:)/grad) - 0.5;
%     psl(i,:) = A * (10 .^ B(i,:));
% end
% toc


