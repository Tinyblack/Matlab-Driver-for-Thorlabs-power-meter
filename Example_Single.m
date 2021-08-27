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
% test_meter.darkAdjust;                                      % (PM400 ONLY)
% test_meter.getDarkOffset;                                   % (PM400 ONLY)
for i=1:1:100   
    test_meter.updateReading(0.5);                          % Update the reading (with interal period of 0.5s)
    fprintf('%.10f%c\r',test_meter.meterPowerReading,test_meter.meterPowerUnit);
end
test_meter.disconnect;                                      % Disconnect and release
