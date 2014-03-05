function kalmanFilterForTracking
    showDetections();
    showTrajectory();
    
    frame            = [];  % A video frame
    detectedLocation = [];  % The detected location
    trackedLocation  = [];  % The tracked location
    label            = '';  % Label for the ball
    utilities        = [];  % Utilities used to process the video

    function trackSingleObject(param)
      % Create utilities used for reading video, detecting moving objects,
      % and displaying the results.
      utilities = createUtilities(param);

      isTrackInitialized = false;
      while ~isDone(utilities.videoReader)
        frame = readFrame();

        % Detect the ball.
        [detectedLocation, isObjectDetected] = detectObject(frame);

        if ~isTrackInitialized
          if isObjectDetected
            % Initialize a track by creating a Kalman filter when the ball is
            % detected for the first time.
            initialLocation = computeInitialLocation(param, detectedLocation);
            kalmanFilter = configureKalmanFilter(param.motionModel, ...
              initialLocation, param.initialEstimateError, ...
              param.motionNoise, param.measurementNoise);

            isTrackInitialized = true;
            trackedLocation = correct(kalmanFilter, detectedLocation);
            label = 'Initial';
          else
            trackedLocation = [];
            label = '';
          end

        else
          % Use the Kalman filter to track the ball.
          if isObjectDetected % The ball was detected.
            % Reduce the measurement noise by calling predict followed by
            % correct.
            predict(kalmanFilter);
            trackedLocation = correct(kalmanFilter, detectedLocation);
            label = 'Corrected';
          else % The ball was missing.
            % Predict the ball's location.
            trackedLocation = predict(kalmanFilter);
            label = 'Predicted';
          end
        end

        annotateTrackedObject();
      end % while

      showTrajectory();
    end

    function param = getDefaultParameters
      param.motionModel           = 'ConstantAcceleration';
      param.initialLocation       = 'Same as first detection';
      param.initialEstimateError  = 1E5 * ones(1, 3);
      param.motionNoise           = [25, 10, 1];
      param.measurementNoise      = 25;
      param.segmentationThreshold = 0.05;
    end

    function frame = readFrame()
      frame = step(utilities.videoReader);
    end

    function showDetections()
      param = getDefaultParameters();
      utilities = createUtilities(param);
      trackedLocation = [];

      idx = 0;
      while ~isDone(utilities.videoReader)
        frame = readFrame();
        detectedLocation = detectObject(frame);
        % Show the detection result for the current video frame.
        annotateTrackedObject();

        % To highlight the effects of the measurement noise, show the detection
        % results for the 40th frame in a separate figure.
        idx = idx + 1;
        if idx == 40
          combinedImage = max(repmat(utilities.foregroundMask, [1,1,3]), frame);
          figure, imshow(combinedImage);
        end
      end % while

      % Close the window which was used to show individual video frame.
      uiscopes.close('All');
    end

    function [detection, isObjectDetected] = detectObject(frame)
      grayImage = rgb2gray(frame);
      utilities.foregroundMask = step(utilities.foregroundDetector, grayImage);
      detection = step(utilities.blobAnalyzer, utilities.foregroundMask);
      if isempty(detection)
        isObjectDetected = false;
      else
        % To simplify the tracking process, only use the first detected object.
        detection = detection(1, :);
        isObjectDetected = true;
      end
    end

    function annotateTrackedObject()
      accumulateResults();
      % Combine the foreground mask with the current video frame in order to
      % show the detection result.
      combinedImage = max(repmat(utilities.foregroundMask, [1,1,3]), frame);

      if ~isempty(trackedLocation)
        shape = 'circle';
        region = trackedLocation;
        region(:, 3) = 5;
        combinedImage = insertObjectAnnotation(combinedImage, shape, ...
          region, {label}, 'Color', 'red');
      end
      step(utilities.videoPlayer, combinedImage);
    end

    function showTrajectory
      % Close the window which was used to show individual video frame.
      uiscopes.close('All');

      % Create a figure to show the processing results for all video frames.
      figure; imshow(utilities.accumulatedImage/2+0.5); hold on;
      plot(utilities.accumulatedDetections(:,1), ...
        utilities.accumulatedDetections(:,2), 'k+');

      if ~isempty(utilities.accumulatedTrackings)
        plot(utilities.accumulatedTrackings(:,1), ...
          utilities.accumulatedTrackings(:,2), 'r-o');
        legend('Detection', 'Tracking');
      end
    end

    function accumulateResults()
      utilities.accumulatedImage      = max(utilities.accumulatedImage, frame);
      utilities.accumulatedDetections ...
        = [utilities.accumulatedDetections; detectedLocation];
      utilities.accumulatedTrackings  ...
        = [utilities.accumulatedTrackings; trackedLocation];
    end

    function loc = computeInitialLocation(param, detectedLocation)
      if strcmp(param.initialLocation, 'Same as first detection')
        loc = detectedLocation;
      else
        loc = param.initialLocation;
      end
    end

    function utilities = createUtilities(param)
      % Create System objects for reading video, displaying video, extracting
      % foreground, and analyzing connected components.
      utilities.videoReader = vision.VideoFileReader('R0016compressed.avi');
      utilities.videoPlayer = vision.VideoPlayer('Position', [100,100,500,400]);
      utilities.foregroundDetector = vision.ForegroundDetector(...
        'NumTrainingFrames', 10, 'InitialVariance', param.segmentationThreshold);
      utilities.blobAnalyzer = vision.BlobAnalysis('AreaOutputPort', false, ...
        'MinimumBlobArea', 200, 'CentroidOutputPort', true);

      utilities.accumulatedImage      = 0;
      utilities.accumulatedDetections = zeros(0, 2);
      utilities.accumulatedTrackings  = zeros(0, 2);
    end
end