close all
clear
meter_list=ThorlabsPowerMeter;                              % Initiate the meter_list
DeviceDescription=meter_list.listdevices;               	% List available device(s)
test_meter_A=meter_list.connect(DeviceDescription,1);       % Connect multiple devices
test_meter_B=meter_list.connect(DeviceDescription,2);       % Connect multiple devices
test_meter_A.setWaveLength(635);                            % Set sensor wavelength
test_meter_B.setWaveLength(780);                            % Set sensor wavelength
test_meter_A.setDispBrightness(0.3);                        % Set display brightness
test_meter_B.setDispBrightness(0.7);                        % Set display brightness
test_meter_A.setAttenuation(-10);                       	% Set Attenuation
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