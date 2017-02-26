X = [1, 0, 0];
Y = [0, 1, 0];
Z = [0, 0, 1];
XAXIS = [1,0,0];
YAXIS = [0,1,0];
ZAXIS = [0,0,1];

AXES = [X,Y,Z];

function get(key, dict) =
    let(x = search(key, dict))
    let(kv = dict[x[0]])
    kv[1];

