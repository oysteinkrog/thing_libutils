XAXIS = [1,0,0];
YAXIS = [0,1,0];
ZAXIS = [0,0,1];
NAXIS = [0,0,0];

X = XAXIS;
Y = YAXIS;
Z = ZAXIS;
N = NAXIS;

XY = X+Y;
XZ = X+Z;
YZ = Y+Z;

AXES = [X,Y,Z];

U = undef;

function get(key, dict) =
    let(x = search(key, dict))
    let(kv = dict[x[0]])
    kv[1];

