import signal_analysis.extract_the_typical

data = rand(2, 3, 5);

%% Shapes
for m = ["mean" "center"]
    assert(isequal( ...
        size(extract_the_typical(data, "Method", m)), ...
        [5 1] ...
    ));
end
