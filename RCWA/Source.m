classdef Source < handle
    % input format S = Source([300:1:400],[30,60],[1,0])
    % source is the the class for incident source
    % Properties for the class
        
    properties (SetAccess = immutable)
        wavelength          % wavelength of the source, unit is nanometer
        angle               % incident angle, unite is radians
        polarization        % polarization of the incident, no unite
        n0                  % unit vector of wave normal
        
        theta               %three angle pairs for three mount types, see [Smith, Erdogan, Erdogan]
        phi
        beta
        rho
        alpha
        xi
    end
    methods
        % Get the input from users
        function s = Source(wavelength,angle,polarization)
        % Purpose: constructor for the source
        % Input: wavelength -- the wavelength range of incident
        %        angle      -- the angle of incident, constructed as array
        %        polarization -- polarization of incident, constructed as
        %        array
                 s.wavelength = wavelength *  RCWA.nanometers;
                 s.angle = angle*RCWA.degrees;
                 s.polarization = polarization;
                 mountType=1;
                 if mountType==1
                     n0=[ sind(angle(1)) * [cosd(angle(2));sind(angle(2))]; cosd(angle(1)) ];%Roll (theta,phi)
                     s.theta=angle(1);
                     s.phi=angle(2);
                 elseif mountType==2
                     n0=[ sind(angle(1)); cosd(angle(1)) * [sind(angle(2));cosd(angle(2))] ];%Pitch (beta,rho)
                     s.beta=angle(1);
                     s.rho=angle(2);
                 elseif mountType==3
                     n0=[ sind(angle(1))*cosd(angle(2)); sind(angle(2)); cosd(angle(1))*cosd(angle(2))];%Lab (alpha,xi)
                     s.alpha=angle(1);
                     s.xi=angle(2);
                 else
                     hdjytjytjrtjrytjrtu
                 end
                 s.n0=n0;
                 if mountType~=1
                     s.theta=acosd(n0(3));
                     h=hypot(n0(1),n0(2));%to generate nans for (0,0) pair
                     s.phi=atan2d(n0(2)/h,n0(1)/h);
                 end
                 if mountType~=2
                     s.beta=asind(n0(1));
                     h=hypot(n0(3),n0(2));%to generate nans for (0,0) pair
                     s.rho=atan2d(n0(2)/h,n0(3)/h);
                 end
                 if mountType~=3
                     h=hypot(n0(3),n0(1));%to generate nans for (0,0) pair
                     s.alpha=atan2d(n0(1)/h,n0(3)/h);
                     s.xi=asind(n0(2));
                 end
%                  if isnan(s.alpha), s.alpha=0; end;
       end
        
       
        function disp(s)
        % Usage: disp(s)
        % Purpose: Disply the data 
        
%             fprintf('Wavelength is from %s micrometer to %s micrometer\n',num2str(s.wavelength(1)),num2str(s.wavelength(end)));
            fprintf('Wavelength is from %s micrometer to %s micrometer\n',num2str(s.smin),num2str(s.smax));
            fprintf('Incident angle theta is %s radians and phi is %s radians\n', num2str(s.angle(1)), num2str(s.angle(2)));
            fprintf('TE and TM is %s and %s\n', num2str(s.polarization(1)),num2str(s.polarization(2)));
        end
        
        
        function snum = snum(s)
        % Purpose: Get the num of the wavelength
            snum =  length(s.wavelength);
        end
        
        function smin = smin(s)
        % Purpose: Get the minimum wavelength 
            smin = min(s.wavelength);
        end
        
        function smax = smax(s)
        % Purpose: Get the maximum wavelength
            smax = max(s.wavelength);
        end
        
        function sk = sk(s,wavelengthnum)
        % Purpose: Get the wave vector conresponding to the wavelength
        % INPUT: the number of the wavelength
        % OUTPUT: k vector in this wavelength
            sk = 2*pi/s.wavelength(wavelengthnum);
        end
        
        
        function skinc = skinc(s,n)
        % Purpose: get the source vector in the reflective region
        % INPUT: n is the reflective of the place that the incident is in
        % OUTPUT: Source vector k
            skinc = n*s.n0;
                
        end  
        
        function [sP,sQ] = sP(s,wavelengthnum,n)
            % caculate vector along polarizations
            % Input: the number of the wavelength
            k0=s.sk(wavelengthnum);
            k=k0*s.skinc(n);            %s.n0 should be enough here
            if s.angle(1) == 0
                a_te = [0;1;0];
            else
                a_te = cross(k,RCWA.sur_nor);
                a_te = a_te/norm(a_te);
            end
            a_tm = cross(a_te,k);
            a_tm = a_tm/norm(a_tm);

            % Composite polarization vector 
            sP = s.polarization(1)*a_te + s.polarization(2)*a_tm;
            sP = sP/norm(sP);
            sQ = conj(s.polarization(2))*a_te - conj(s.polarization(1))*a_tm;   %transverse polarization
            sQ = sQ/norm(sQ);
        end
            
     end
        
end



        