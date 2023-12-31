classdef SerialEbyteDriver < realtime.internal.SourceSampleTime & ...
        coder.ExternalDependency
    %
    % System object template for a source block.
    % N - Multiplicity of smaller sampling period with respect to T=0.1s or N=1 if it is equal to T=0.1s of the block sampling period
    % 
    % This template includes most, but not all, possible properties,
    % attributes, and methods that you can implement for a System object in
    % Simulink.
    %
    % NOTE: When renaming the class name Source, the file name and
    % constructor name must be updated to use the class name.
    %
    
    % Copyright 2016-2018 The MathWorks, Inc.
    %#codegen
    %#ok<*EMCA>
    
    properties

    end
    
    % Public, non-tunable properties.
    properties (Nontunable)
        serialID = 0; % Serial ID {0,1,2,3}
        dataSendLength = 16; % Data Send Length (bytes)
        dataRecvLength = 16; % Data Recv Length (bytes)
    end
    
    properties (Access = private)
        % Pre-computed constants.
    end
    
    methods
        % Constructor
        function obj = SerialEbyteDriver(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation setup code here
            else
                % Call C-function implementing device initialization
                coder.cinclude('SerialEbyteDriver.h');
                coder.ceval('SerialEbyteDriver_Init', int8(obj.serialID));
            end
        end
        
        function [dataRecv, statusRecv] = stepImpl(obj, dataSend, enSend)   %#ok<MANU>
            dataRecv = zeros(1, obj.dataRecvLength,'uint8');
            statusRecv = int8(0);
            if isempty(coder.target)
                % Place simulation output code here
            else
                coder.ceval('SerialEbyteDriver_Step_Send', int8(obj.dataSendLength), dataSend, enSend);  
                coder.ceval('SerialEbyteDriver_Step_Recv', int8(obj.dataRecvLength), coder.wref(dataRecv), coder.wref(statusRecv));
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation termination code here
            else
                % Call C-function implementing device termination
                %coder.ceval('SerialEbyteDriver_terminate');
            end
        end
    end
    
    methods (Access=protected)
        %% Define output properties
        function num = getNumInputsImpl(~)
            num = 2;
        end
        
        function num = getNumOutputsImpl(~)
            num = 2;
        end

        function flag = isInputSizeMutableImpl(~,~)
            flag = false;
        end

        function flag = isInputComplexityMutableImpl(~,~)
            flag = false;
        end

        function validateInputsImpl(~, dataSend, enSend)
            if isempty(coder.target)
                % Run input validation only in Simulation
                validateattributes(dataSend,{'uint8'},{'row'},'','dataSend');
                validateattributes(enSend,{'uint8'},{'scalar'},'','enSend');
            end
        end
        
        function varargout = isOutputFixedSizeImpl(~,~)
            varargout{1} = true;
            varargout{2} = true;
        end
        
        
        function varargout = isOutputComplexImpl(~)
            varargout{1} = false;
            varargout{2} = false;
        end
        
        function varargout = getOutputSizeImpl(obj)
            varargout{1} = [1, obj.dataRecvLength];
            varargout{2} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout{1} = 'uint8';
            varargout{2} = 'int8';
        end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'SerialEbyteDriver';
        end    
    end
    
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'SerialEbyteDriver';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                % Update buildInfo
                srcDir = fullfile(fileparts(mfilename('fullpath')),'src'); 
                includeDir = fullfile(fileparts(mfilename('fullpath')),'include');

                % Include header files
                addIncludePaths(buildInfo, includeDir);

                % Include source files
                addSourceFiles(buildInfo, 'SerialEbyteDriver.cpp', srcDir);
    
                boardInfo = arduino.supportpkg.getBoardInfo;
        
                switch boardInfo.Architecture
                    case 'avr'
                        % Add SPI Library - For AVR Based
                        ideRootPath = arduino.supportpkg.getAVRRoot;
                        addIncludePaths(buildInfo, fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'SPI', 'src'));
                        srcFilePath = fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'SPI', 'src');
                        fileNameToAdd = {'SPI.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                        % Add Wire / I2C Library - For AVR Based
                        addIncludePaths(buildInfo, fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src'));
                        addIncludePaths(buildInfo, fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src', 'utility'));
                        srcFilePath = fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src');
                        fileNameToAdd = {'Wire.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                        srcFilePath = fullfile(ideRootPath, 'hardware', 'arduino', 'avr', 'libraries', 'Wire', 'src', 'utility');
                        fileNameToAdd = {'twi.c'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                    case 'sam'
                        % Add SPI Library - For SAM Based
                        libSAMPath = arduino.supportpkg.getSAMLibraryRoot;
                        addIncludePaths(buildInfo, fullfile(libSAMPath, 'SPI','src'));
                        srcFilePath = fullfile(libSAMPath, 'SPI','src');
                        fileNameToAdd = {'SPI.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                        % Add Wire / I2C Library - For SAM Based
                        addIncludePaths(buildInfo, fullfile(libSAMPath, 'Wire', 'src'));
                        srcFilePath= fullfile(libSAMPath, 'Wire', 'src');
                        fileNameToAdd = {'Wire.cpp'};
                        addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
%                     case 'samd'
%                         % Add SPI Library - For SAMD Based
%                         libSAMDPath = arduino.supportpkg.getSAMDLibraryRoot;
%                         addIncludePaths(buildInfo, fullfile(libSAMDPath, 'SPI'));
%                         srcFilePath = fullfile(libSAMDPath, 'SPI');
%                         fileNameToAdd = {'SPI.cpp'};
%                         addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
%                 
%                         % Add Wire / I2C Library - For SAMD Based
%                         addIncludePaths(buildInfo, fullfile(libSAMDPath, 'Wire'));
%                         srcFilePath= fullfile(libSAMDPath, 'Wire');
%                         fileNameToAdd = {'Wire.cpp'};
%                         addSourceFiles(buildInfo, fileNameToAdd, srcFilePath);
                
                    otherwise
                        warning('Unexpected board type. Check again.')
                  end


%                 Use the following API's to add include files, sources and
%                 linker flags
%                 addIncludeFiles(buildInfo,'source.h',includeDir);
%                 addSourceFiles(buildInfo,'source.c',srcDir);
%                 addLinkFlags(buildInfo,{'-lSource'});
%                 addLinkObjects(buildInfo,'sourcelib.a',srcDir);
%                 addCompileFlags(buildInfo,{'-D_DEBUG=1'});
%                 addDefines(buildInfo,'MY_DEFINE_1')
            end
        end
    end
end
