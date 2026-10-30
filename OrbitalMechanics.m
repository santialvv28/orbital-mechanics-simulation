% ORBITAL MECHANICS SIMULATION
clear;
close all;
clc;

% VALUES
mu = 398600;
R_earth = 6378; 
altitude = 400;

% EQUATIONS
r0 = R_earth + altitude;
v0 = sqrt(mu/r0);
x0 = r0;
y0 = 0;
vx0 = 0;
vy0 = v0;

% SIMULATION SETUP

state0 = [x0; y0; vx0; vy0];
tspan = [0 6000];
options = odeset('Events', @(t, state) collisionEvent(t,state,R_earth), ...
    'RelTol',1e-10, 'AbsTol',1e-12);
[t, state, te] = ode45(@(t,state) orbitODE(t,state,mu), tspan, state0, options);

% GRAPH SETUP
x = state(:,1);
y = state(:,2);

figure;
hold on;

% DRAW EARTH
theta = linspace(0, 2*pi, 300);
earth_x = R_earth * cos(theta);
earth_y = R_earth * sin(theta);

fill(earth_x, earth_y, [0.2 0.5 1]);

% DRAW ORBIT
plot(x, y, 'k', 'LineWidth', 2,'Color','m');

% STARTING POSITION
plot(x0, y0, 'ro', 'MarkerFaceColor', 'y');

axis equal;
grid on;

xlabel('x [km]');
ylabel('y [km]');
title('2D Orbital Mechanics Simulation');

legend('Earth', 'Orbit', 'Starting Position');

% CALCULATIONS
orbital_period = 2*pi*sqrt(r0^3 / mu);
orbital_period_minutes = orbital_period / 60;

fprintf('Orbital Period: %.2f minutes\n', orbital_period_minutes);

specific_energy = v0^2/2 - mu/r0;
fprintf('Specific Orbital Energy %.2f km^2/s^2\n', specific_energy);

specific_angular_momentum = r0*v0;
fprintf('Specific Angular Momnentum %.2f km^2/s\n', specific_angular_momentum);

semi_major_axis = -mu / (2*specific_energy);
eccentricity = sqrt(1+(2*specific_energy*specific_angular_momentum^2)/(mu^2));

fprintf('Semi-Major Axis: %.2f km\n', semi_major_axis);
fprintf('Eccentricity: %.5f\n', eccentricity);


% VALUES THROUGHOUT ORBIT
vx = state(:,3);
vy = state (:,4);
r = sqrt(x.^2 + y.^2);
v = sqrt(vx.^2 + vy.^2);
energy = v.^2/2 - mu./r;
angular_momentum = x.*vy - y.*vx;

figure;
plot(t, energy, 'b', 'LineWidth', 2);
grid on;
xlabel('Time [s]');
ylabel('Specific Energy [km^2/s^2]');
title('Specific Orbital Energy vs Time');

figure;
plot(t, angular_momentum, 'g', 'LineWidth',3);
grid on;
xlabel ('Time [s]');
ylabel('Specific Angular Momentum [km^2/s]')
title('Specific Angular Momentum vs Time')

function dstate = orbitODE(~, state, mu)
 x = state(1);
 y = state(2);
 vx = state(3);
 vy = state(4);
 r = sqrt(x^2 + y^2);
 ax = -mu*x/r^3;
 ay = -mu*y/r^3;
 dstate = [vx; vy; ax; ay];
end

function [value, isterminal, direction] = collisionEvent(~,state,R_earth)
x = state(1);
y = state(2);
r = sqrt(x.^2 + y.^2);
value = r - R_earth;
isterminal = 1;
direction = -1;
end

if isempty(te)
    fprintf('Simulation completed without impact.\n');
else
    fprintf('Simulation interrupted due to collision into earth at %.2f seconds.\n', te);
end

% END