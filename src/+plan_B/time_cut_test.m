import plan_B.time_cut

%% Shapes
data = rand(13, 3);
assert(isequal( ...
    size(time_cut(data)), ...
    size(data) ...
));

%% Ideal signal
data = [zeros(1, 10) ones(1, 5) zeros(1, 10) ones(1, 5) zeros(1, 10)].';
assert(isequal( ...
    time_cut(data, "SamplingRate", 1, "DurationEstimated", 5), ...
    data ...
));

%% Negligible noise
data = [zeros(1, 10) ones(1, 5) zeros(1, 10) ones(1, 5) zeros(1, 10)].';
with_noise = data + 0.1 * ones(size(data));
assert(isequal( ...
    time_cut(with_noise, "SamplingRate", 1, "DurationEstimated", 5), ...
    data ...
));