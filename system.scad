XAXIS = [1,0,0];
YAXIS = [0,1,0];
ZAXIS = [0,0,1];
AXES = [XAXIS,YAXIS,ZAXIS];

function get(key, dict) =
    let(x = search(key, dict))
    let(kv = dict[x[0]])
    kv[1];

