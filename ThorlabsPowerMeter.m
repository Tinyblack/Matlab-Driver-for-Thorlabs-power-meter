classdef ThorlabsPowerMeter < matlab.mixin.Copyable
    %ThorlabsPowerMeter Matlab class to control Thorlabs power meters
    %   Driver for Thorlabs power meter
    %   It is a 'wrapper' to control Thorlabs devices via the Thorlabs .NET
    %   DLLs.
    %
    %   User Instructions:
    %       1. Download the Optical Power Monitor from the Thorlabs website:
    %       https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=OPM
    %       [The latest version is 4.0.4100.700 - Accessed on 01 SEP 2022]
    %
    %       2. Read the manual in the installation folder or the sofware help page
    %       https://www.thorlabs.com/software/MUC/OPM/v3.0/TL_OPM_V3.0_web-secured.pdf
    %
    %       3. Following the instructions in section 9: Write Your Own Application
    %       The common path of the *.dll files on Windows is:
    %       C:\Program Files\IVI Foundation\VISA\VisaCom64\Primary Interop Assemblies\Thorlabs.TLPM_64.Interop.dll
    %
    %       4. This scripts need only the .net wrapper dll so follow the instruction for C#/.Net
    %
    %       5. Edit MOTORPATHDEFAULT below to point to the location of the DLLs
    %
    %       6. Connect your Power Meter with sensor to the PC USB port and power it on.
    %
    %       7. Please refer to the examples provided
    %
    %   For developers:
    %   The definition for all the classes can be found in the C sharp exmple
    %   provided by Thorlab. (Shipped together with the software.)
    %
    %   Example:
    %   close all
    %   clear
    %   meter_list=ThorlabsPowerMeter;                              % Initiate the meter_list
    %   DeviceDescription=meter_list.listdevices;               	% List available device(s)
    %   test_meter=meter_list.connect(DeviceDescription);           % Connect single/the first devices
    %   %or                                                         % Connect single/the first devices
    %   %test_meter=meter_list.connect(DeviceDescription,1);        % Connect single/the first devices
    %   test_meter.setWaveLength(635);                              % Set sensor wavelength
    %   test_meter.setDispBrightness(0.3);                          % Set display brightness
    %   test_meter.setAttenuation(0);                               % Set Attenuation
    %   test_meter.sensorInfo;                                      % Retrive the sensor info
    %   test_meter.setPowerAutoRange(1);                            % Set Autorange
    %   % or
    %   % test_meter.setPowerRange(0.01);                           % Set manual range
    %   pause(5)                                                    % Pause the program a bit to allow the power meter to autoadjust
    %   test_meter.setAverageTime(0.01);                            % Set average time for the measurement
    %   test_meter.setTimeout(1000);                                % Set timeout value 
    %   % test_meter.darkAdjust;                                      % (PM400 ONLY)
    %   % test_meter.getDarkOffset;                                   % (PM400 ONLY)
    %   for i=1:1:100   
    %       test_meter.updateReading(0.5);                          % Update the power reading(with interal period of 0.5s)
    %       fprintf('%.10f%c\r',test_meter.meterPowerReading,test_meter.meterPowerUnit);
    %   end
    %   test_meter.updateReading_V(0.5);                            % To demonstrate that only certain sensors can use this function
    %                                                               % A warning message is expected here for most of the models
    %   test_meter.disconnect;                                      % Disconnect and release
    %
    %   Author: Zimo Zhao
    %   Dept. Engineering Science, University of Oxford, Oxford OX1 3PJ, UK
    %   Email: zimo.zhao@eng.ox.ac.uk (please email issues and bugs)
    %   Website: https://eng.ox.ac.uk/smp/
    %   GitHub: https://github.com/Tinyblack/Matlab-Driver-for-Thorlabs-power-meter
    %
    %   Initially Developed On:
    %       Optical Power Monitor
    %           Application 3.1.3778.562
    %           TLPM__32 5.1.3754.327
    %       Matlab
    %           2020b
    %   
    %   Test pass:
    %       Optical Power Monitor
    %           Application 4.0.4100.700
    %           TLPMX__32 5.3.4101.525
    %       Matlab
    %           2022a
    %
    %   Version History:
    %   1.00 ----- 21 May 2021 ----- Initial Release
    %   1.01 ----- 17 Aug 2021 ----- Clarify the way of utilizing *.dll files
    %   2.00 ----- 27 Aug 2021 ----- Support multiple power meters connection
    %   2.01 ----- 26 Sep 2021 ----- Add force connection function to bypass the device availability check.
    %   3.00 ----- 01 Feb 2022 ----- Add functions: setPowerRange, setPowerAutoRange, setTimeout, setAverageTime, updateReading_V
    %   3.10 ----- 01 SEP 2022 ----- Test the script on latest TLPM driver and MATLAB. Some bugs are corrected as well

    
    properties (Constant, Hidden)
        % Path to .net *.dll files (edit as appropriate)
        % pwd --- Current working directory of this file
        % (depending on the location where you put this file)
        % This line points to folder 'Thorlabs_DotNet_dll' under the same directory
        % Comment out this line and uncomment next line to use customized dll file directory
        METERPATHDEFAULT=[pwd '\Thorlabs_DotNet_dll\'];
        %METERPATHDEFAULT=['---Your---Own---Path---'];
        
        %   *.dll files to be loaded
        %
        % NOTE
        %   No significant difference was noticed between 
        %   "Thorlabs.TLPMX_64.Interop.dll" and "Thorlabs.TLPM_64.Interop.dll"
        %   But if you are going to use "Thorlabs.TLPMX_64.Interop.dll", please change 
        %
        %         TLPMDLL='Thorlabs.TLPM_64.Interop.dll';
        %         TLPMCLASSNAME='Thorlabs.TLPM_64.Interop.TLPM';
        %     
        %     into
        %         
        %         TLPMDLL='Thorlabs.TLPMX_64.Interop.dll';
        %         TLPMCLASSNAME='Thorlabs.TLPM_64.Interop.TLPMX';
        %
        TLPMDLL='Thorlabs.TLPM_64.Interop.dll';
        TLPMCLASSNAME='Thorlabs.TLPM_64.Interop.TLPM';
    end
    
    properties
        % These properties are within Matlab wrapper
        isConnected=false;          % Flag set if device connected
        resourceName;               % USB resource name
        resourceNameConnected;      % USB resource name
        modelName;                  % Power meter model name
        serialNumber;               % Power meter serial number
        Manufacturer;               % Power meter manufacturer
        DeviceAvailable;            % Power meter avaliablity
        numberOfResourceName;       % Number of available resources
        sensorName;                 % Sensor name
        sensorSerialNumber;         % Sensor serial number
        sensorCalibrationMessage;   % Sensor calibration information
        sensorType;                 % Sensor type
        sensorSubType;              % Sensor subtype
        sensorFlags;                % Sensor flag
        DarkOffset_Voltage;         % (PM400 ONLY) Dark offset voltage
        DarkOffset_Voltage_Unit;    % (PM400 ONLY) Dark offset voltage unit
        meterPowerReading;          % Power reading
        meterPowerUnit;             % Power reading unit
        meterVoltageReading;        % Voltage reading
        meterVoltageUnit;           % Voltage reading unit
    end
    
    properties (Hidden)
        % These are properties within the .NET environment.
        deviceNET;                  % Device object within .NET
    end
    
    methods
        function obj = ThorlabsPowerMeter()
            %ThorlabsPowerMeter Construct an instance of this class
            %   This function first loads the dlls from the path and then
            %   list all the device available. It will return a list of all
            %   the available device(s).
            obj.loaddlls;
            [obj.resourceName,obj.modelName,obj.serialNumber,obj.Manufacturer,obj.DeviceAvailable]=obj.listdevices;
            if isempty(obj.resourceName)
                obj.isConnected=false;
                warning('No Resource is found, please check the connection.');
            else
                obj.numberOfResourceName=size(obj.resourceName,1);
                fprintf('Found the following %d device(s):\r',obj.numberOfResourceName);
                for i=1:1:size(obj.resourceName,1)
                    fprintf('\t\t%d) %s\r',i,obj.resourceName(i,:));
                end
                fprintf('Use <Your_Meter_List>.connect(resourceName) to connect a single/the first device.\r');
                fprintf('or\r');
                fprintf('Use <Your_Meter_List>.connect(resourceName,index) to connect multiple devices.\r\r');
            end
        end
        
        function delete(obj)
            %DELETE Deconstruct the instance of this class
            %   Usage: obj.delete;
            %   This function disconnects the device and exits.
            if obj.isConnected
                try
                    warning('Program Terminated with Device Connected.');
                    obj.disconnect;
                catch
                    warning('Failed to release the device.');
                end
            else % Cannot disconnect because device is not connected
                %fprintf('Device Released Properly.\r\r');
            end
            
        end
        
        function obj_copy=connect(obj,resource,resource_index,ID_Query,Reset_Device)
            %CONNECT Connect to the specified resource.
            %   Usage: obj.connect(resource);
            %   By default, it will connect to the first resource on the
            %   list [resource_index=1] with ID query [ID_Query=1] and
            %   reset [Reset_Device=1];
            %   Use
            %   obj.connect(resource,ID_Query,Reset_Device,resource_index)
            %   to modify the default values.
            arguments
                obj
                resource
                resource_index (1,1) {mustBeNumeric} = 1 % (default) First resource
                ID_Query (1,1) {mustBeNumeric} = 1 % (default) Query the ID
                Reset_Device (1,1) {mustBeNumeric} = 1 % (default) Reset
            end
            %obj.listdevices;
            if ~obj.isConnected
                try
                    obj_copy=copy(obj);
                    % The core method to create the power meter instance
                    obj_copy.deviceNET=Thorlabs.TLPM_64.Interop.TLPM(resource(resource_index,:),logical(ID_Query),logical(Reset_Device));
                    fprintf('Successfully connect the device:\r\t\t%s\r',resource(resource_index,:));
                    obj_copy.resourceNameConnected=resource(resource_index,:);
                    obj_copy.isConnected=true;
                    obj_copy.modelName=obj.modelName{resource_index};
                    obj_copy.serialNumber=obj.serialNumber(resource_index,:);
                    obj_copy.Manufacturer=obj_copy.Manufacturer(resource_index,:);
                    obj.DeviceAvailable(resource_index)=0;
                    obj.isConnected=false;
                catch
                    error('Failed to connect the device.');
                end
            else
                if obj.isConnected==1
                    warning('Device is connected.');
                end
                if obj.DeviceAvailable(resource_index)==0
                    warning('Device is not available.');
                end
                obj_copy=[];
            end
        end
        
        function obj_copy=connectForce(obj,resource,resource_index,ID_Query,Reset_Device)
            %CONNECT Force connect to the specified resource regradless of it status.
            %   Usage: obj.connectForce(resource);
            %   By default, it will connect to the first resource on the
            %   list [resource_index=1] with ID query [ID_Query=1] and
            %   reset [Reset_Device=1] regradless of it status (Availability);
            %   Use
            %   obj.connectForce(resource,ID_Query,Reset_Device,resource_index)
            %   to modify the default values.
            arguments
                obj
                resource
                resource_index (1,1) {mustBeNumeric} = 1 % (default) First resource
                ID_Query (1,1) {mustBeNumeric} = 1 % (default) Query the ID
                Reset_Device (1,1) {mustBeNumeric} = 1 % (default) Reset
            end
            %obj.listdevices;
            try
                obj_copy=copy(obj);
                % The core method to create the power meter instance
                warning('[Force Connection. The actual device may not be connected]\n');
                obj_copy.deviceNET=Thorlabs.TLPM_64.Interop.TLPM(resource(resource_index,:),logical(ID_Query),logical(Reset_Device));
                fprintf('Successfully connect the device:\r\t\t%s\r',resource(resource_index,:));
                obj_copy.resourceNameConnected=resource(resource_index,:);
                obj_copy.isConnected=true;
                obj_copy.modelName=obj.modelName{resource_index};
                obj_copy.serialNumber=obj.serialNumber(resource_index,:);
                obj_copy.Manufacturer=obj_copy.Manufacturer(resource_index,:);
                obj.DeviceAvailable(resource_index)=0;
                obj.isConnected=false;
            catch
                error('Failed to connect the device.');
            end
        end
        
        function disconnect(obj)
            %DISCONNECT Disconnect the specified resource.
            %   Usage: obj.disconnect;
            %   Disconnect the specified resource.
            if obj.isConnected
                fprintf('\tDisconnecting ... %s\r',obj.resourceNameConnected);
                try
                    obj.deviceNET.Dispose();  %Disconnect the device
                    obj.isConnected=false;
                    fprintf('\tDevice Released Properly.\r\r');
                catch
                    warning('Unable to disconnect device.');
                end
            else % Cannot disconnect because device not connected
                warning('Device not connected.')
            end
        end
        
        function setAverageTime(obj,AverageTime)
            %SETAVERAGETIME Set the sensor average time.
            %   Usage: obj.setAverageTime(AverageTime);
            %   Set the sensor average time. This method will check the input
            %   and force it to a vaild value if it is out of the range.
            [~,AverageTime_MIN]=obj.deviceNET.getAvgTime(1);
            [~,AverageTime_MAX]=obj.deviceNET.getAvgTime(2);
            if (AverageTime_MIN<=AverageTime && AverageTime<=AverageTime_MAX)
                obj.deviceNET.setAvgTime(AverageTime);
                fprintf('\tSet Average Time to %.4fs\r',AverageTime);
            else
                if AverageTime_MIN>AverageTime
                    warning('Exceed minimum average time! Force to the minimum.');
                    obj.deviceNET.setAvgTime(AverageTime_MIN);
                    fprintf('\tSet Average Time to %.4fs\r',AverageTime_MIN);
                end
                if AverageTime>AverageTime_MAX
                    warning('Exceed maximum average time! Force to the maximum.');
                    obj.deviceNET.setAvgTime(AverageTime_MAX);
                    fprintf('\tSet Average Time to %.4fs\r',AverageTime_MAX);
                end
            end
        end
        
        function setTimeout(obj,Timeout)
            %SETTIMEOUT Set the power meter timeout value.
            %   Usage: obj.setTimeout(Timeout);
            %   Set the sensor timeout value.
            obj.deviceNET.setTimeoutValue(Timeout);
            fprintf('\tSet Timeout Value to %.4fms\r',Timeout);
        end
        
        function setWaveLength(obj,wavelength)
            %SETWAVELENGTH Set the sensor wavelength.
            %   Usage: obj.setWaveLength(wavelength);
            %   Set the sensor wavelength. This method will check the input
            %   and force it to a vaild value if it is out of the range.
            [~,wavelength_MIN]=obj.deviceNET.getWavelength(1);
            [~,wavelength_MAX]=obj.deviceNET.getWavelength(2);
            if (wavelength_MIN<=wavelength && wavelength<=wavelength_MAX)
                obj.deviceNET.setWavelength(wavelength);
                fprintf('\tSet wavelength to %.4f\r',wavelength);
            else
                if wavelength_MIN>wavelength
                    warning('Exceed minimum wavelength! Force to the minimum.');
                    obj.deviceNET.setWavelength(wavelength_MIN);
                    fprintf('\tSet wavelength to %.4f\r',wavelength_MIN);
                end
                if wavelength>wavelength_MAX
                    warning('Exceed maximum wavelength! Force to the maximum.');
                    obj.deviceNET.setWavelength(wavelength_MAX);
                    fprintf('\tSet wavelength to %.4f\r',wavelength_MAX);
                end
            end
        end
        
        function setPowerAutoRange(obj,enable)
            obj.deviceNET.getPowerRange(enable);
        end
        
        function setPowerRange(obj,range)
            %SETPOWERRANGE Set the sensor power range.
            %   Usage: obj.setPowerRange(range);
            %   Set the sensor power range. This method will check the input
            %   and force it to a vaild value if it is out of the range.
            [~,range_MIN]=obj.deviceNET.getPowerRange(1);
            [~,range_MAX]=obj.deviceNET.getPowerRange(2);
            if (range_MIN<=range && range<=range_MAX)
                obj.deviceNET.setPowerRange(range);
                fprintf('\tSet range to %.4f\r',range);
            else
                if range_MIN>range
                    warning('Exceed minimum range! Force to the minimum.');
                    obj.deviceNET.setPowerRange(range_MIN);
                    fprintf('\tSet range to %.4f\r',range_MIN);
                end
                if range>range_MAX
                    warning('Exceed maximum range! Force to the maximum.');
                    obj.deviceNET.setPowerRange(range_MAX);
                    fprintf('\tSet range to %.4f\r',range_MIN);
                end
            end
        end
        
        function setDispBrightness(obj,Brightness)
            %SETDISPBRIGHTNESS Set the display brightness.
            %   Usage: obj.setDispBrightness(Brightness);
            %   Set the display brightness. This method will check the input
            %   and force it to a vaild value if it is out of the range.
            if (0.0<=Brightness && Brightness<=1.0)
                obj.deviceNET.setDispBrightness(Brightness);
            else
                if 0.0>Brightness
                    warning('Exceed minimum brightness! Force to the minimum.');
                    Brightness=0.0;
                    obj.deviceNET.setDispBrightness(Brightness);
                end
                if Brightness>1.0
                    warning('Exceed maximum brightness! Force to the maximum.');
                    Brightness=1.0;
                    obj.deviceNET.setDispBrightness(Brightness);
                end
            end
            fprintf('Set Display Brightness to %d%%\r',Brightness*100);
        end
        
        function setAttenuation(obj,Attenuation)
            %SETATTENUATION Set the attenuation.
            %   Usage: obj.setAttenuation(Attenuation);
            %   Set the attenuation.
            if any(strcmp(obj.modelName,{'PM100A', 'PM100D', 'PM100USB', 'PM200', 'PM400'}))
                [~,Attenuation_MIN]=obj.deviceNET.getAttenuation(1);
                [~,Attenuation_MAX]=obj.deviceNET.getAttenuation(2);
                if (Attenuation_MIN<=Attenuation && Attenuation<=Attenuation_MAX)
                    obj.deviceNET.setAttenuation(Attenuation);
                else
                    if Attenuation_MIN>Attenuation
                        warning('Exceed minimum Attenuation! Force to the minimum.');
                        Attenuation=Attenuation_MIN;
                        obj.deviceNET.setAttenuation(Attenuation);
                    end
                    if Attenuation>Attenuation_MAX
                        warning('Exceed maximum Attenuation! Force to the maximum.');
                        Attenuation=Attenuation_MAX;
                        obj.deviceNET.setAttenuation(Attenuation);
                    end
                end
                fprintf('Set Attenuation to %.4f dB, %.4fx\r',Attenuation,10^(Attenuation/20));
            else
                warning('This command is not supported on %s.',obj.modelName);
            end
        end
        
        function sensorInfo=sensorInfo(obj)
            %SENSORINFO Retrive the sensor information.
            %   Usage: obj.sensorInfo;
            %   Read the information of sensor connected and store it in
            %   the properties of the object.
            for i=1:1:3
                descr{i}=System.Text.StringBuilder;
                descr{i}.Capacity=1024;
            end
            [~,type,subtype,sensor_flag]=obj.deviceNET.getSensorInfo(descr{1}, descr{2}, descr{3});
            obj.sensorName=char(descr{1}.ToString);
            obj.sensorSerialNumber=char(descr{2}.ToString);
            obj.sensorCalibrationMessage=char(descr{3}.ToString);
            switch type
                case 0x00
                    obj.sensorType='No sensor';
                    switch subtype
                        case 0x00
                            obj.sensorSubType='No sensor';
                        otherwise
                            warning('Unknown sensor.');
                    end
                case 0x01
                    obj.sensorType='Photodiode sensor';
                    switch subtype
                        case 0x01
                            obj.sensorSubType='Photodiode adapter';
                        case 0x02
                            obj.sensorSubType='Photodiode sensor';
                        case 0x03
                            obj.sensorSubType='Photodiode sensor with integrated filter identified by position';
                        case 0x12
                            obj.sensorSubType='Photodiode sensor with temperature sensor';
                        otherwise
                            warning('Unknown sensor.');
                    end
                case 0x02
                    obj.sensorType='Thermopile sensor';
                    switch subtype
                        case 0x01
                            obj.sensorSubType='Thermopile adapter';
                        case 0x02
                            obj.sensorSubType='Thermopile sensor';
                        case 0x12
                            obj.sensorSubType='Thermopile sensor with temperature sensor';
                        otherwise
                            warning('Unknown sensor.');
                    end
                case 0x03
                    obj.sensorType='Pyroelectric sensor';
                    switch subtype
                        case 0x01
                            obj.sensorSubType='Pyroelectric adapter';
                        case 0x02
                            obj.sensorSubType='Pyroelectric sensor';
                        case 0x12
                            obj.sensorSubType='Pyroelectric sensor with temperature sensor';
                        otherwise
                            warning('Unknown sensor.');
                    end
                otherwise
                    warning('Unknown sensor.');
            end
            tag=rem(sensor_flag,16);
            switch tag
                case 0x0000
                    
                case 0x0001
                    obj.sensorFlags=[obj.sensorFlags,'Power sensor '];
                case 0x0002
                    obj.sensorFlags=[obj.sensorFlags,'Energy sensor '];
                otherwise
                    warning('Unknown flag.');
            end
            sensor_flag=sensor_flag-tag;
            tag=rem(sensor_flag,256);
            switch tag
                case 0x0000
                    
                case 0x0010
                    obj.sensorFlags=[obj.sensorFlags,'Responsivity settable '];
                case 0x0020
                    obj.sensorFlags=[obj.sensorFlags,'Wavelength settable '];
                case 0x0040
                    obj.sensorFlags=[obj.sensorFlags,'Time constant settable '];
                otherwise
                    warning('Unknown flag.');
            end
            sensor_flag=sensor_flag-tag;
            tag=rem(sensor_flag,256*16);
            switch tag
                case 0x0000
                    
                case 0x0100
                    obj.sensorFlags=[obj.sensorFlags,'With Temperature sensor '];
                otherwise
                    warning('Unknown flag.');
            end
            sensorInfo.Type=obj.sensorType;
            sensorInfo.SubType=obj.sensorSubType;
            sensorInfo.Flags=obj.sensorFlags;
        end
        
        function updateReading(obj,period)
            %UPDATEREADING Update the reading from power meter.
            %   Usage: obj.updateReading;
            %   Retrive the reading from power meter and store it in the
            %   properties of the object
            [~,obj.meterPowerReading]=obj.deviceNET.measPower;
            pause(period)
            [~,meterPowerUnit_]=obj.deviceNET.getPowerUnit;
            switch meterPowerUnit_
                case 0
                    obj.meterPowerUnit='W';
                case 1
                    obj.meterPowerUnit='dBm';
                otherwise
                    warning('Unknown');
            end
        end
        
        function updateReading_V(obj,period)
            %UPDATEREADING_V Update the reading from power meter with Voltage reading.
            %   Usage: obj.updateReading;
            %   Retrive the reading from power meter and store it in the
            %   properties of the object
            %   Only for PM100D, PM100A, PM100USB, PM160T, PM200, PM400
            %   ANd it only support certain sensors
            [~,obj.meterPowerReading]=obj.deviceNET.measPower;
            pause(period)
            [~,meterPowerUnit_]=obj.deviceNET.getPowerUnit;
            switch meterPowerUnit_
                case 0
                    obj.meterPowerUnit='W';
                case 1
                    obj.meterPowerUnit='dBm';
                otherwise
                    warning('Unknown');
            end
            if any(strcmp(obj.modelName,{'PM100D', 'PM100A', 'PM100USB', 'PM160T', 'PM200', 'PM400'}))
                try
                    [~,obj.meterVoltageReading]=obj.deviceNET.measVoltage; 
                    obj.meterVoltageUnit='V';
                catch
                    warning('Wrong sensor type for this operation');
                end
            end
        end
        
        
        
        function darkAdjust(obj)
            %DARKADJUST (PM400 Only) Initiate the Zero value measurement.
            %   Usage: obj.darkAdjust;
            %   Start the measurement of Zero value.
            if any(strcmp(obj.modelName,'PM400'))
                obj.deviceNET.startDarkAdjust;
                [~,DarkState]=obj.deviceNET.getDarkAdjustState;
                while DarkState
                    [~,DarkState]=obj.deviceNET.getDarkAdjustState;
                end
            else
                warning('This command is not supported on %s.',obj.modelName);
            end
        end
        
        function [DarkOffset_Voltage,DarkOffset_Voltage_Unit]=getDarkOffset(obj)
            %GETDARKOFFSET (PM400 Only) Read the Zero value from powermeter.
            %   Usage: [DarkOffset_Voltage,DarkOffset_Voltage_Unit]=obj.getDarkOffset;
            %   Retrive the Zero value from power meter and store it in the
            %   properties of the object
            if any(strcmp(obj.modelName,'PM400'))
                [~,DarkOffset_Voltage]=obj.deviceNET.getDarkOffset;
                DarkOffset_Voltage_Unit='V';
                obj.DarkOffset_Voltage=DarkOffset_Voltage;
                obj.DarkOffset_Voltage_Unit=DarkOffset_Voltage_Unit;
            else
                warning('This command is not supported on %s.',obj.modelName);
            end
        end
        
    end
    
    methods (Static)
        function [resourceName,modelName,serialNumber,Manufacturer,DeviceAvailable]=listdevices()  % Read a list of resource names
            %LISTDEVICES List available resources.
            %   Usage: obj.listdevices;
            %   Retrive all the available devices and return it back.
            ThorlabsPowerMeter.loaddlls; % Load DLLs
            findResource=Thorlabs.TLPM_64.Interop.TLPM(System.IntPtr);  % Build device list
            [~,count]=findResource.findRsrc; % Get device list
            for i=1:1:4
                descr{i}=System.Text.StringBuilder;
                descr{i}.Capacity=2048;
            end
            if count>0
                for i=0:1:count-1
                    findResource.getRsrcName(i,descr{1});
                    [~,Device_Available]=findResource.getRsrcInfo(i, descr{2}, descr{3}, descr{4});
                    resourceNameArray(i+1,:)=char(descr{1}.ToString);
                    modelNameArray{i+1}=char(descr{2}.ToString);
                    serialNumberArray(i+1,:)=char(descr{3}.ToString);
                    ManufacturerArray(i+1,:)=char(descr{4}.ToString);
                    DeviceAvailableArray(i+1,:)=Device_Available;
                end
                resourceName=resourceNameArray;
                modelName=modelNameArray;
                serialNumber=serialNumberArray;
                Manufacturer=ManufacturerArray;
                DeviceAvailable=DeviceAvailableArray;
            else
                resourceName=[];
                modelName=[];
                serialNumber=[];
                Manufacturer=[];
                DeviceAvailable=[];
            end
            findResource.Dispose();
        end
        function loaddlls() % Load DLLs
            %LOADDLLS Load needed dll libraries.
            %   Usage: obj.loaddlls;
            %   Change the path of dll to suit you application.
            if ~exist(ThorlabsPowerMeter.TLPMCLASSNAME,'class')
                try   % Load in DLLs if not already loaded
                    NET.addAssembly([ThorlabsPowerMeter.METERPATHDEFAULT,ThorlabsPowerMeter.TLPMDLL]);
                catch % DLLs did not load
                    error('Unable to load .NET assemblies')
                end
            end
        end
    end
end

