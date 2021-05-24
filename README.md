[![View Matlab-Driver-for-Thorlabs-power-meter on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/92803-matlab-driver-for-thorlabs-power-meter)

# Matlab Driver for Thorlabs Power Meter

This is a Matlab class to control Thorlabs power meters

[Link](https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=10562) to a typical Thorlabs Power Meter. (For Central File Exchange: The file image comes from this link as well.)

## User Instructions:

1. Download the Optical Power Monitor from the Thorlabs [website](https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=OPM).
2. Read the manual in the installation folder or the [software help page](https://www.thorlabs.com/software/MUC/OPM/v3.0/TL_OPM_V3.0_web-secured.pdf).
3. Following the instructions in section 9: **Write Your Own Application**.
4. This scripts need only the .net wrapper dll so follow the instruction for C#.
5. Edit MOTORPATHDEFAULT below to point to the location of the DLLs.
6. Connect your Power Meter with sensor to the PC USB port and power it on.

## For developers:

1. The definition for all the classes can be found in the C# exmple provided by Thorlab. (Shipped together with the software.)

## Example Usage:

```matlab
clear
test_meter=ThorlabsPowerMeter;            % Initiate the object
DeviceDescription=test_meter.listdevices; % List available device(s)
test_meter.connect(DeviceDescription);    % Connect selected device
test_meter.setWaveLength(780);            % Set sensor wavelength
test_meter.setDispBrightness(0.5);        % Set display brightness
test_meter.setAttenuation(0);             % Set Attenuation
test_meter.sensorInfo;                    % Retrive the sensor info
test_meter.darkAdjust;                    % (PM400 ONLY)
test_meter.getDarkOffset;                 % (PM400 ONLY)
test_meter.updateReading;                 % Update the reading
test_meter.disconnect;                    % Disconnect and release resource
```

## Author Information:

* Author: Zimo Zhao
* Dept. Engineering Science, University of Oxford, Oxford OX1 3PJ, UK
* Email: zimo.zhao@emg.ox.ac.uk (please email issues and bugs)
* Website: https://eng.ox.ac.uk/smp/

## Known Issues:

1. This program is not yet suitable for multiple power meters connection.
2. More functions to be added in the future.

## Version History:

1.00 ----- 21 May 2021 ----- Initial Release
