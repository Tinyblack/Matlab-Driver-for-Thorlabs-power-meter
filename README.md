[![View Matlab-Driver-for-Thorlabs-power-meter on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/92803-matlab-driver-for-thorlabs-power-meter)

# Matlab Driver for Thorlabs Power Meter

This is a Matlab class to control Thorlabs power meters. (Multiple meters are supported)

[Link](https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=10562) to a typical Thorlabs Power Meter.

## User Instructions:

1. Download the Optical Power Monitor from the Thorlabs [website](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=OPM).
2. Read the manual in the installation folder or the [software help page](https://www.thorlabs.com/software/MUC/OPM/v3.0/TL_OPM_V3.0_web-secured.pdf).
3. Following the instructions in section 9: **Write Your Own Application**.
4. This scripts need only the .net wrapper dll so follow the instruction for C#.
5. Two ways of utilising the dynamic link library (*.dll) files provided by Thorlabs:
   1. Copy *.dll files needed to ''Thorlabs_DotNet_dll'' folder (e.g. Thorlabs.TLPM_64.Interop.dll).
   2. Edit MOTORPATHDEFAULT below to point to the location of the DLLs.
6. Connect your Power Meter with sensor to the PC USB port and power it on.

## For developers:

1. The definition for all the classes can be found in the C# exmple provided by Thorlab. (Shipped together with the software.) [The typical path for x64 system is C:\Program Files (x86)\IVI Foundation\VISA\WinNT\TLPM\Example]

## Example Single Usage:

```matlab
close all
clear
meter_list=ThorlabsPowerMeter;                              % Initiate the meter_list
DeviceDescription=meter_list.listdevices;               	% List available device(s)
test_meter=meter_list.connect(DeviceDescription);           % Connect single/the first devices
%or                                                         % Connect single/the first devices
%test_meter=meter_list.connect(DeviceDescription,1);        % Connect single/the first devices
test_meter.setWaveLength(635);                              % Set sensor wavelength
test_meter.setDispBrightness(0.3);                          % Set display brightness
test_meter.setAttenuation(0);                               % Set Attenuation
test_meter.sensorInfo;                                      % Retrive the sensor info
test_meter.setPowerAutoRange(1);                            % Set Autorange
% or
% test_meter.setPowerRange(0.01);                           % Set manual range
pause(5)                                                    % Pause the program a bit to allow the power meter to autoadjust
test_meter.setAverageTime(0.01);                            % Set average time for the measurement
test_meter.setTimeout(1000);                                % Set timeout value 
% test_meter.darkAdjust;                                      % (PM400 ONLY)
% test_meter.getDarkOffset;                                   % (PM400 ONLY)
for i=1:1:100   
    test_meter.updateReading(0.5);                          % Update the power reading(with interal period of 0.5s)
    fprintf('%.10f%c\r',test_meter.meterPowerReading,test_meter.meterPowerUnit);
    test_meter.updateReading_V(0.5);                        % Update the power reading with voltage reading(with interal period of 0.5s)
    fprintf('%.10f%c\r',test_meter.meterPowerReading,test_meter.meterPowerUnit);
    fprintf('\t%.10f%c\r',test_meter.meterVoltageReading,test_meter.meterVoltageUnit);
end
test_meter.disconnect;                                      % Disconnect and release
```

## Example Multiple Usage:

```matlab
close all
clear
meter_list=ThorlabsPowerMeter;                              % Initiate the meter_list
DeviceDescription=meter_list.listdevices;                   % List available device(s)
test_meter_A=meter_list.connect(DeviceDescription,1);       % Connect multiple devices
test_meter_B=meter_list.connect(DeviceDescription,2);       % Connect multiple devices
test_meter_A.setWaveLength(635);                            % Set sensor wavelength
test_meter_B.setWaveLength(780);                            % Set sensor wavelength
test_meter_A.setDispBrightness(0.3);                        % Set display brightness
test_meter_B.setDispBrightness(0.7);                        % Set display brightness
test_meter_A.setAttenuation(-10);                           % Set Attenuation
test_meter_B.setAttenuation(10);                            % Set Attenuation
% test_meter_A.sensorInfo;                                  % Retrive the sensor info
% test_meter_B.sensorInfo;                                  % Retrive the sensor info
% test_meter_A.darkAdjust;                                  % (PM400 ONLY)
% test_meter_A.getDarkOffset;                               % (PM400 ONLY)
% test_meter_B.darkAdjust;                                  % (PM400 ONLY)
% test_meter_B.getDarkOffset;                               % (PM400 ONLY)
for i=1:1:100   
    test_meter_A.updateReading(0.5);                        % Update the reading (with interal period of 0.5s)
    fprintf('%.10f%c\r',test_meter_A.meterPowerReading,test_meter_A.meterPowerUnit);
end
fprintf('\r');
for i=1:1:100
    test_meter_B.updateReading(0.5);                        % Update the reading (with interal period of 0.5s)
    fprintf('%.10f%c\r',test_meter_B.meterPowerReading,test_meter_B.meterPowerUnit);
end
test_meter_A.disconnect;                                    % Disconnect and release
test_meter_B.disconnect;                                    % Disconnect and release
```

## Author Information:

* Author: Zimo Zhao
* Dept. Engineering Science, University of Oxford, Oxford OX1 3PJ, UK
* Email: zimo.zhao@eng.ox.ac.uk
* Website: https://eng.ox.ac.uk/smp/
* Reporting issues and bugs to my Github repository is more welcomed.

## Known Issues:

1. If the measuring period is too small, some errors may occur. If it happens, restart MATLAB as well as power meters.

## TODO

1. More functions to be added in the future.
2. Test the codes on more power meters (Currently, PM100D and PM400 are tested.)
3. Add default values to some functions

## Version History:

1.00 ----- 21 May 2021 ----- Initial Release

1.01 ----- 17 Aug 2021 ----- Clarify the way of utilizing *.dll files

2.00 ----- 27 Aug 2021 ----- Support multiple power meters connection

2.01 ----- 26 Sep 2021 ----- Add force connection function to bypass the device availability check.

3.00 ----- 01 Feb 2022 ----- Add functions: setPowerRange, setPowerAutoRange, setTimeout, setAverageTime, updateReading_V
