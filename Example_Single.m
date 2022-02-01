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
