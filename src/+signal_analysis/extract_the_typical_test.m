import signal_analysis.extract_the_typical

data = rand(4, 3, 5, 2);

%% Shapes
for m = ["mean" "center", "random"]
    assert(isequal( ...
        size(extract_the_typical(data, "Method", m)), ...
        [5 2] ...
    ));
end
