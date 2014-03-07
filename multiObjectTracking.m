function multiObjectTracking()
    obj = setupSystemObjects();
    tracks = initializeTracks();
    nextId = 1; %i ID of next track
    
    frameCount = 0;

    output = VideoWriter('R0016_20140306_13-05-30_005_s_track.avi', 'Motion JPEG AVI');
    output.Quality = 60;
    output.FrameRate = 30;
    open(output);

    % Let's do this...
    while ~isDone(obj.reader)
        frameCount = frameCount + 1;
        frame = readFrame();
        [centroids, bboxes, mask] = detectObjects(frame);
        predictNewLocationsOfTracks();
        [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment();

        updateAssignedTracks();
        updateUnassignedTracks();
        deleteLostTracks();
        createNewTracks();

        displayTrackingResults();
    end
    
    close(output);

    function obj = setupSystemObjects()
        obj.reader = vision.VideoFileReader('R0016_20140306_13-05-30_005_s.avi');
%         obj.videoPlayer = vision.VideoPlayer('Position', [20, 900, 900, 600]);
        
        obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 10, 'MinimumBackgroundRatio', .7);
        
        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea', 150);
    end

    function tracks = initializeTracks()
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end

    function frame = readFrame()
        frame = obj.reader.step();
    end

    function [centroids, bboxes, mask] = detectObjects(frame)
        % Rememeber, frame is an image
        % Detect object using mask
        mask = obj.detector.step(frame);

        % Morph mask a bit
        mask = imopen(mask, strel('disk', 10, 0));
        mask = imfill(mask, 'holes');
        
        % Build green mask for color extraction using HSV color space
        % and windowing/thresholds
        hsv = rgb2hsv(frame);

        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        h(h < .25 | h > .45) = 0;
        h(s < .15) = 0;
        h(v < .07) = 0;
        
        h = imopen(h, strel('disk', 3, 0));
        h = imfill(h, 'holes');
        h = imdilate(h, strel('disk', 1, 0));

        greenMask = logical(h);
        
        manualMask = logical(imread('R0016_20140306_13-06-25_013_s_mask.png'));
        mask = greenMask & manualMask;
        
%         rframe = frame(:,:,1);
%         rframe(edge(mask)) = 255;
%         frame(:,:,1) = rframe;
%         frame = im2uint8(frame);
%         imshow(frame);
        
        %writeVideo(output, im2frame(uint8(frame)));
        
        % perform blob analysis to find connected components
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;

            % predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);

            % shift the bounding box so that its centered
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end

    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()

        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        if(~isempty(centroids))
            csize = size(centroids);
            for i=1:csize(1);
                frame = insertObjectAnnotation(frame, 'circle',... 
                    [centroids(i,:), 3], '.', 'Color', 'blue',...
                    'TextBoxOpacity', 0, 'FontSize', 8);
            end
        end

        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end

        % Solve the assignment problem.
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);

            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);

            % Replace predicted bounding box with detected
            % bounding box.
            tracks(trackIdx).bbox = bbox;

            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;

            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    end

    function deleteLostTracks()
        if isempty(tracks)
            return;
        end

        invisibleForTooLong = 8;
        ageThreshold = 4;

        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;

        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

        % Delete lost tracks.
        tracks = tracks(~lostInds);
    end

    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);

        for i = 1:size(centroids, 1)

            centroid = centroids(i,:);
            bbox = bboxes(i, :);

            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);

            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);

            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;

            % Increment the next id.
            nextId = nextId + 1;
        end
    end

    function displayTrackingResults()
        % Convert the frame and the mask to uint8 RGB.
        frame = im2uint8(frame);
        rframe = frame(:,:,1);
        rframe(edge(mask)) = 255;
        frame(:,:,1) = rframe;
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

        minVisibleCount = 5;
        if ~isempty(tracks)

            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);

            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % Get bounding boxes.
                bboxes = cat(1, reliableTracks.bbox);

                % Get ids.
                ids = int32([reliableTracks(:).id]);

                % Create labels for objects
                labels = cellstr(int2str(ids'));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};
                labels = strcat(labels, isPredicted);

                % Draw the objects on the frame.
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, '.', 'TextBoxOpacity', 0);
                writeVideo(output, im2frame(frame));

                
            end
        end

%         obj.videoPlayer.step(frame);
    end

end