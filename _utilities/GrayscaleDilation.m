classdef GrayscaleDilation< visionhdl.internal.abstractLineMemoryKernel
%GrayscaleDilation Morphological dilation on a grayscale pixel stream.
%  morphDilate = visionhdl.GrayscaleDilation returns a System object,
%  morphDilate, that performs morphological dilation of an input
%  stream based on the input control signals.
%
%  morphDilate = visionhdl.GrayscaleDilation('PropertyName',PropertyValue,...)
%  returns a dilation System object, morphDilate, with each specified
%  property set to the specified value.
%
%  morphDilate = visionhdl.GrayscaleDilation(Nhood,'PropertyName',PropertyValue,...)
%  returns a dilation System object, morphDilate, with the
%  Neighborhood property set to Nhood, other specified properties set
%  to the specified values.
%
%  Step method syntax:
%  [pixOut,ctrlOut] = step(morphDilate,pixIn,ctrlIn) performs
%  morphological dilation. ctrlIn and ctrlOut are structures consisting
%  of five control signals. See also <a href="matlab:doc visionhdl.FrameToPixels">visionhdl.FrameToPixels</a> or
%  <a href="matlab:doc pixelcontrolstruct">pixelcontrolstruct</a>.
%
%  System objects may be called directly like a function instead of using
%  the step method. For example, y = step(obj, x) and y = obj(x) are
%  equivalent.
%
%  GrayscaleDilation methods:
%
%   step     - See above description for use of this method
%   release  - Allow property value and input characteristics changes
%   clone    - Create a GrayscaleDilation object with same property values
%   isLocked - Locked status (logical)
%
%  GrayscaleDilation properties:
%
%   Neighborhood   - Neighborhood values
%   LineBufferSize - Line buffer size
%
% % EXAMPLE:
% % Perform morphological dilation on an image.
% frm2pix = visionhdl.FrameToPixels(...
%     'VideoFormat','custom',...
%     'ActivePixelsPerLine',32,...
%     'ActiveVideoLines',18,...
%     'TotalPixelsPerLine',42,...
%     'TotalVideoLines',28,...
%     'StartingActiveLine',6,...
%     'FrontPorch',5);
% [actPixPerLine,actLine,numPixPerFrm] = getparamfromfrm2pix(frm2pix);
%
% pix2frm = visionhdl.PixelsToFrame(...
%     'VideoFormat','custom',...
%     'ActivePixelsPerLine',actPixPerLine,...
%     'ActiveVideoLines',actLine);
%
% morphDilate = visionhdl.GrayscaleDilation;
%
% frmFull = imread('peppers.png');
% frmIn = imresize(rgb2gray(frmFull),[actLine actPixPerLine]);
% imshow(frmIn);
%
% pixOutVec = ones(numPixPerFrm,1,'uint8');
% ctrlOutVec = repmat(pixelcontrolstruct,numPixPerFrm,1);
%
% [pixInVec,ctrlInVec] = step(frm2pix,frmIn);
% for p = 1:numPixPerFrm
%     [pixOutVec(p),ctrlOutVec(p)] = step(morphDilate,pixInVec(p),ctrlInVec(p));
% end
% [frmOut,frmValid] = step(pix2frm,pixOutVec,ctrlOutVec);
%
% if frmValid
%     figure;
%     imshow(frmOut);
% end
%
%   See also IMDILATE.

 
    %   Copyright 2015-2023 The MathWorks, Inc.

    methods
        function out=GrayscaleDilation
        end

        function out=getExecutionSemanticsImpl(~) %#ok<STOUT>
            % works in both classic and synchronous subsystems
        end

        function out=getHeaderImpl(~) %#ok<STOUT>
            %getHeaderImpl   Return header for object display
        end

        function out=getIconImpl(~) %#ok<STOUT>
        end

        function out=getInputNamesImpl(~) %#ok<STOUT>
        end

        function out=getNumInputsImpl(~) %#ok<STOUT>
        end

        function out=getNumOutputsImpl(~) %#ok<STOUT>
        end

        function out=getOutputDataTypeImpl(~) %#ok<STOUT>
        end

        function out=getOutputNamesImpl(~) %#ok<STOUT>
        end

        function out=getOutputSizeImpl(~) %#ok<STOUT>
        end

        function out=isOutputComplexImpl(~) %#ok<STOUT>
        end

        function out=isOutputFixedSizeImpl(~) %#ok<STOUT>
        end

        function out=kernellatency(~) %#ok<STOUT>
            % Compute the latency for Grayscale Dilation kernel
            % PipeLine Delay
        end

        function out=loadObjectImpl(~) %#ok<STOUT>
        end

        function out=outputImpl(~) %#ok<STOUT>
            % Call to function handle - see private methods for actual computation...
        end

        function out=resetImpl(~) %#ok<STOUT>
        end

        function out=saveObjectImpl(~) %#ok<STOUT>
            % Save the public properties
        end

        function out=setupImpl(~) %#ok<STOUT>
        end

        function out=showSimulateUsingImpl(~) %#ok<STOUT>
        end

        function out=supportsMultipleInstanceImpl(~) %#ok<STOUT>
            % Support in For Each Subsystem
        end

        function out=updateImpl(~) %#ok<STOUT>
            % Call to function handle - see private methods for actual computation...
        end

        function out=validateInputsImpl(~) %#ok<STOUT>
            %coder.extrinsic('validatecontrolsignals');
        end

    end
    properties
        %LineBufferSize visionhdl:GrayscaleMorphology:LineBufferSize
        %   Specify the size of the line buffer. The value should be greater than
        %   or equal to (ActivePixelsPerLine / NumberOfPixelsPerCycle). The
        %   default value of this property is 2048.
        LineBufferSize;

        %Neighborhood visionhdl:GrayscaleMorphology:Neighborhood
        %   Specify the morphological structuring element as a 2-D pixel
        %   neighborhood of up to 32x32 binary values where row vectors
        %   must consist of 8 or more elements. The default value of this
        %   property is ones(3, 3).
        Neighborhood;

    end
end
