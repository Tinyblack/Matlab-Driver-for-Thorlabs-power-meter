
1) Two ways of utilising the dynamic link library (*.dll) files provided by Thorlabs:

    _> Copy *.dll files needed to this folder (e.g. Thorlabs.TLPM_64.Interop.dll)

    _> Change the path value of METERPATHDEFAULT in the class.

2) According to the manual provided by Thorlabs, usually the files will be at: 
C:\Program Files\IVI Foundation\VISA\VisaCom64\Primary Interop Assemblies\Thorlabs.TLPM_64.Interop.dll

3) No significant difference was noticed between "Thorlabs.TLPMX_64.Interop.dll" and "Thorlabs.TLPM_64.Interop.dll"
But if you are going to use "Thorlabs.TLPMX_64.Interop.dll", please change 

    TLPMDLL='Thorlabs.TLPM_64.Interop.dll';
    TLPMCLASSNAME='Thorlabs.TLPM_64.Interop.TLPM';

into
    
    TLPMDLL='Thorlabs.TLPMX_64.Interop.dll';
    TLPMCLASSNAME='Thorlabs.TLPM_64.Interop.TLPMX';

in "ThorlabsPowerMeter.m"
