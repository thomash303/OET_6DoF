% temp = tempdir;
% current = 'OpenModelica\OMEdit';
% file = '\OET.Example.multibodyWEC\multibodyWEC_res.csv';
% 
% filedir = [temp current file];
% 
% T = readtable(filedir);

DoF = 6;
modes = ["Surge", "Sway", "Heave", "Roll", "Pitch", "Yaw"];
bodies = 1;
bodyName = {'float', 'spar'};

% Kinematics
% Kinematic component names
kinematicNames = {'position', 'velocity' 'acceleration'};
displacements = {'r_1_', 'r_2_', 'r_3_', 'angles_1_', 'angles_2_', 'angles_3_'};
velocities = {'v_1_', 'v_2_', 'v_3_', 'w_1_', 'w_2_', 'w_3_'};
accelerations = {'a_1_', 'a_2_', 'a_3_', 'z_1_', 'z_2_', 'z_3_'};
kinQuantities = [displacements; velocities; accelerations];
units = {'m','m','m','rad','rad','rad';
    'm/s','m/s','m/s','rad/s','rad/s','rad/s';
    'm/s^2','m/s^2','m/s^2','rad/s^2','rad/s^2','rad/s^2'};

velocity = zeros(2896,3);
for i = 1:3
    tempName = ['spar_body_absoluteSensor_v_' num2str(i) '_'];
    velocity(:,i) = T.(tempName);
end