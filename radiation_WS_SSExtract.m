% 
% nDOF = 6;
% dofStart = 1;
% dofEnd = 6;
% rho = 1000;
% arrayCounter = 0;
% Af = [];
% Bf = [];
% Cf = [];
% Df = [];
% 
% for ii = 1:nDOF
%     for jj = dofStart:dofEnd
%         jInd = jj-dofStart+1;
%         arraySize = body.hydroData.hydro_coeffs.radiation_damping.state_space.it(ii,jj);
%         arrayCounter = arraySize + arrayCounter;
%         if ii == 1 && jInd == 1 % Begin construction of combined state, input, and output matrices
%             Af(1:arraySize,1:arraySize) = body.hydroData.hydro_coeffs.radiation_damping.state_space.A.all(ii,jj,1:arraySize,1:arraySize);
%             Bf(1:arraySize,jInd)        = body.hydroData.hydro_coeffs.radiation_damping.state_space.B.all(ii,jj,1:arraySize,1);
%             Cf(ii,1:arraySize)          = body.hydroData.hydro_coeffs.radiation_damping.state_space.C.all(ii,jj,1,1:arraySize);
%         else
%             Af(size(Af,1)+1:size(Af,1)+arraySize,size(Af,2)+1:size(Af,2)+arraySize) = body.hydroData.hydro_coeffs.radiation_damping.state_space.A.all(ii,jj,1:arraySize,1:arraySize);
%             Bf(size(Bf,1)+1:size(Bf,1)+arraySize,jInd) = body.hydroData.hydro_coeffs.radiation_damping.state_space.B.all(ii,jj,1:arraySize,1);
%             Cf(ii,size(Cf,2)+1:size(Cf,2)+arraySize)   = body.hydroData.hydro_coeffs.radiation_damping.state_space.C.all(ii,jj,1,1:arraySize);
%         end
%     end
% end
% ssRadf.D = zeros(nDOF,nDOF);
% 
% ssRadf.A = Af;
% ssRadf.B = Bf;
% ssRadf.C = Cf .*rho;

filename = 'C:\Users\thogan1\Documents\GitHub\OceanEngineeringToolbox\RM3\hydroData\rm3.h5';
% CHECK DIALOG SELECTOR
% CHECK APP

% Hydrostatics
rho = h5read(filename,'/simulation_parameters/rho');                          % Density of water
g = h5read(filename,'/simulation_parameters/g');                              % Acceleration due to gravity
hydroCoeff.m33 = rho * h5read(filename,'/body1/properties/disp_vol');         % Equilibrium mass
hydroCoeff.Ainf33 = rho * h5read(filename,'/body1/hydro_coeffs/added_mass/inf_freq',[3 3],[1 1]);           % Infinite-frequency added mass
hydroCoeff.Khs33 = rho * g * h5read(filename,'/body1/hydro_coeffs/linear_restoring_stiffness',[3 3],[1 1]); % Linear hydrostatic stiffness

% Radiation state-space matrices
hydroCoeff.ss_rad33.A = h5read(filename,'/body1/hydro_coeffs/radiation_damping/state_space/A/all');   % Time-invariant state-space state matrix
hydroCoeff.ss_rad33.B = h5read(filename,'/body1/hydro_coeffs/radiation_damping/state_space/B/all');   % Time-invariant state-space input matrix
hydroCoeff.ss_rad33.C = h5read(filename,'/body1/hydro_coeffs/radiation_damping/state_space/C/all');   % Time-invariant state-space output matrix
hydroCoeff.ss_rad33.D = h5read(filename,'/body1/hydro_coeffs/radiation_damping/state_space/D/all');   % Time-invariant state-space feed-through matrix

% Excitation coefficients
hydroCoeff.w = h5read(filename,'/simulation_parameters/w');                   % Frequency values
hydroCoeff.FexcRe2 = h5read(filename,'/body1/hydro_coeffs/excitation/re');    % Real component of wave excitation force coefficient
hydroCoeff.FexcIm2 = h5read(filename,'/body1/hydro_coeffs/excitation/im');    % Imaginary component of wave excitation force coefficient

% Matrix transformation to remove non-heave modes

for i = 1:6
    Size = hydro.coefficients.radiation.stateSpace.order(i,i);
    tempName = ['n' num2str(i)];
    if i == 1  % Begin construction of combined state, input, and output matrices

  A.(tempName) = squeeze(hydroCoeff.ss_rad33.A(:,:,i,i));
    B.(tempName) = squeeze(hydroCoeff.ss_rad33.B(:,:,i,i));
    C.(tempName) = squeeze(hydroCoeff.ss_rad33.C(:,:,i,i));
        
    else
             A.(tempName) = squeeze(hydroCoeff.ss_rad33.A(:,:,i,i));
             B.(tempName) = squeeze(hydroCoeff.ss_rad33.B(:,:,i,i));
             C.(tempName)   = squeeze(hydroCoeff.ss_rad33.C(:,:,i,i));
    end

end



hydroCoeff.FexcRe(1,:) = hydroCoeff.FexcRe2(:,:,3);
hydroCoeff.FexcIm(1,:) = hydroCoeff.FexcIm2(:,:,3);

% Strip rows and columns with all 0 values
hydroCoeff.ss_rad33.A( ~any(hydroCoeff.ss_rad33.A,2), : ) = [];  % SS matrix A - rows
hydroCoeff.ss_rad33.A( :, ~any(hydroCoeff.ss_rad33.A,1) ) = [];  % SS matrix A - columns
hydroCoeff.ss_rad33.A = hydroCoeff.ss_rad33.A.';

hydroCoeff.ss_rad33.B( ~any(hydroCoeff.ss_rad33.B,2), : ) = [];  % SS matrix B - rows
hydroCoeff.ss_rad33.B( :, ~any(hydroCoeff.ss_rad33.B,1) ) = [];  % SS matrix B - columns
hydroCoeff.ss_rad33.B = hydroCoeff.ss_rad33.B.';

hydroCoeff.ss_rad33.C( ~any(hydroCoeff.ss_rad33.C,2), : ) = [];  % SS matrix C - rows
hydroCoeff.ss_rad33.C( :, ~any(hydroCoeff.ss_rad33.C,1) ) = [];  % SS matrix C - columns
hydroCoeff.ss_rad33.C = rho.*hydroCoeff.ss_rad33.C.';

hydroCoeff.ss_rad33.D( ~any(hydroCoeff.ss_rad33.D,2), : ) = [];  % SS matrix D - rows
hydroCoeff.ss_rad33.D( :, ~any(hydroCoeff.ss_rad33.D,1) ) = [];  % SS matrix D - columns
hydroCoeff.ss_rad33.D = rho.*hydroCoeff.ss_rad33.D;

% Export the MATLAB structure.
save('hydroCoeff.mat')

%% Next steps

% After running this section, build the simulation in the OET using
% the MATLAB structure by specifying the file location in the import
% statements. After simulation, export the OET variables by referring to
% the user documentation.