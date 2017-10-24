include <system.scad>
use <scad-utils/linalg.scad>
use <scad-utils/lists.scad>

function posvec(path_vec) = [for(v=path_vec) translation_part(v)];
function posvec_x(path_vec) = [for(v=path_vec) translation_part(v)[0]];
function posvec_y(path_vec) = [for(v=path_vec) translation_part(v)[1]];
function posvec_z(path_vec) = [for(v=path_vec) translation_part(v)[2]];

function vec_i(v3,i) = [for(v=v3) v[i]];
function vec_0(v3) = vec_i(v3,0);
function vec_1(v3) = vec_i(v3,1);
function vec_2(v3) = vec_i(v3,2);

// if V is array and len == 1, return single value, otherwise return V
function singlify(V) = len(V)==1?V[0]:V;
if($test_mode)
{
    assert_v(singlify("t"),"t");
    assert_v(singlify("test"),"test");
    assert_v(singlify(0),0);
    assert_v(singlify([]),[]);
    assert_v(singlify([0]),0);
    assert_v(singlify([0,1]),[0,1]);
}

function v_itrlen(vec) = [0:1:len(vec)-1];

function range1(v1) = [min(v1), max(v1)];
function range3(v3) = [range1(vec_0(v3)), range1(vec_1(v3)), range1(vec_2(v3))];
function bbox(r) = [ [r[0][0],r[1][0],r[2][0]], [r[0][1],r[1][1],r[2][1]] ];
function transform_pp(vec_m, t_pre, t_post) = [for(m=vec_m) (t_pre*m)*t_post];
function transform_pre(vec_m, t) = [for(m=vec_m) t*m];
function transform_post(vec_m, t) = [for(m=vec_m) m*t];

function clamp(v, v1, v2) = min(max(v,v1),v2);

// from the start (or s'th element) to the e'th element - remember elements are zero based
function v_sum(v,e=U,start=0) =
let(e_= fallback(e, len(v)-1))
(e==start ? v[e] : v[e_] + v_sum(v,e_-1,start));

function v_i(vec,i) = [for(vv=vec) vv[i]];
function v_get(vec,key) = [for(vv=vec) get(key, vv)];
function v_add(vec,v) = [for(vv=vec) vv+v];
function v_sub(vec,v) = [for(vv=vec) vv+v];
function v_mul(A,B) = [for(i=[0:len(A)-1]) A[i]*B[i]];
function v_avg(v,e=U,start=0) = v_sum(v,e,start) / (len(v));
function v_abs(v, start=0) = [for(i=[start:1:len(v)-1]) abs(v[i])];
function v_sign(v, start=0) = [for(i=[start:1:len(v)-1]) sign(v[i])];
function v_max(v, m, start=0) = [for(i=[start:1:len(v)-1]) max(v[i],m)];
function v_min(v, m, start=0) = [for(i=[start:1:len(v)-1]) min(v[i],m)];
function v_clamp(v, v1, v2, start=0) = [for(i=[start:1:len(v)-1]) clamp(v[i],v1,v2)];

function v_slice(v, start, end) =
let(start_ = start==U?0:start)
let(end_ = end==U?len(v)-1:end)
[for(i=[start_:1:end_]) v[i]];

if($test_mode)
{
    v=[0,1,2];
    assert_v(v_slice(v), [0, 1,2]);
    assert_v(v_slice(v,start=1), [1,2]);
    assert_v(v_slice(v,end=1), [0, 1]);
    assert_v(v_slice(v,start=1,end=1), [1]);
}

// cumulative sum of vector [1,2,3] = [1,3,6]
function v_cumsum(v, start=0, end) = [for(i=[start:1:end==U?len(v)-1:end]) v_sum(v,i)];

// filter/remove a val from a vec
function filter(vec,val=U) = [for(v=vec) if(v!=val) v];

function vec_pair_double_transform_post(vec,t1,t2)=
    flatten(
        [for(v=vec)
            [transform_post(v,t1),transform_post(v,t2)]
        ]);

function vec_pair_double(vec)=flatten([for(v=vec) [v,v] ]);

/** Calculates length of hypotenuse according to pythagoras */
function pythag_hyp(a, b)=sqrt(a*a+b*b);
function pythag_leg(b, c)=sqrt(c*c-b*b);


function v_x(v) = [v[0],0,0];
function v_y(v) = [0,v[1],0];
function v_z(v) = [0,0,v[2]];

function v_xy(v) = [v[0],v[1],0];
function v_xyz(v) = [v[0],v[1],v[2]];
function v_yz(v) = [0,v[1],v[2]];
function v_z(v) = [0,0,v[2]];

//-- Calculate the module/magnitude of a vector
function v_mod(v) = (sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]));

//-- Calculate the cross product of two vectors
function v_cross(u,v) = [
  u[1]*v[2] - v[1]*u[2],
  u[2]*v[0] - v[2]*u[0],
  u[0]*v[1] - v[0]*u[1]
];

//-- Calculate the dot product of two vectors
function v_dot(u,v) = u[0]*v[0]+u[1]*v[1]+u[2]*v[2];

//-- Return the unit vector of a vector
function v_unitv(v) = v/v_mod(v);

//-- Return the angle between two vectores
function v_anglev(u,v) = acos( v_dot(u,v) / (v_mod(u)*v_mod(v)) );

function _orient_angles(zaxis)=
[
    -asin(zaxis.y / norm(zaxis)),
    atan2(zaxis.x, zaxis.z),
    0
];

/*function _orient_angles_(v)=*/
/*[*/
    /*-atan2(sqrt(v.x*v.x+v.y*v.y), v.z),*/
    /*0,*/
    /*-atan2(v.x, v.z)*/
/*];*/

//matrix rotation functions
function _rotate_x_matrix(a)=
[[1,0,0,0],
    [0,cos(a),-sin(a),0],
    [0,sin(a),cos(a),0],
    [0,0,0,1]];

function _rotate_y_matrix(a)=
[[cos(a),0,sin(a),0],
    [0,1,0,0],
    [-sin(a),0,cos(a),0],
    [0,0,0,1]];

function _rotate_z_matrix(a)=
[[cos(a),-sin(a),0,0],
    [sin(a),cos(a),0,0],
    [0,0,1,0],
    [0,0,0,1]];

function _rotate_matrix(a)=_rotate_z_matrix(a.z)*_rotate_y_matrix(a.y)*_rotate_x_matrix(a.x);

//hadamard product (aka "component-wise" product) for vectors
function hadamard(v1,v2) = [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];

// search in a dictionary (vector w/key-value pairs) and replace the value for a given key
function dict_replace(dict, key, newvalue)=[
        for(kv=dict)
        kv[0] == key ?
            [key, newvalue]
            :
            kv
        ];

function dict_replace_multiple(dict, newvaluesdict)=[
    for(kv_old=dict)
    let(r = search(kv_old[0], newvaluesdict, num_returns_per_match=0, index_col_num=0))
    r==[]?kv_old:newvaluesdict[r[0]]
    ];

function sinh(x) = (1 - pow(e, -2 * x)) / (2 * pow(e, -x));
function cosh(x) = (1 + pow(e, -2 * x)) / (2 * pow(e, -x));
function tanh(x) = sinh(x) / cosh(x);
function cot(x) = 1 / tan(x);

function factorial(n) = n == 0 ? 1 : factorial(n - 1) * n;

if(false)
{
    vec=[ 10, 20, 30, 40 ];
    echo("v_sum=", v_sum(vec,2,1)); // is 20+30=50
    echo("v_sum=", v_sum(vec));
    echo("v_cumsum=", v_cumsum(vec));
}

// FUNCTION: is_String(x)
//   Returns true if x is a string, false otherwise.
function is_string(x) =
	x == U || len(x) == U
		? false // if U, a boolean or a number
		: len(str(x,x)) == len(x)*2; // if an array, this is false


// FUNCTION: is_array(x)
//   Returns true if x is an array, false otherwise.
function is_array(x) = is_string(x) ? false : len(x) != U;

function identity(d)        = d == 0 ? 1 : [for(y=[1:d]) [for(x=[1:d]) x == y ? 1 : 0] ];
function unit_vector(v)     = let(x=v[0], y=v[1], z=v[2]) [x/norm(v), y/norm(v), z/norm(v)];
function skew_symmetric(v)  = let(x=v[0], y=v[1], z=v[2]) [[0, -z, y], [z, 0, -x], [-y, x, 0]];
function tensor_product1(u) = let(x=u[0], y=u[1], z=u[2]) [[x*x, x*y, x*z], [x*y, y*y, y*z], [x*z, y*z, z*z]];
function v_rotate(a, v)
    = is_array(a)
? let(rx=a[0], ry=a[1], rz=a[2])
    [[1, 0, 0],              [0, cos(rx), -sin(rx)], [0, sin(rx), cos(rx)]]
  * [[cos(ry), 0, sin(ry)],  [0, 1, 0],              [-sin(ry), 0, cos(ry)]]
  * [[cos(rz), -sin(rz), 0], [sin(rz), cos(rz), 0],  [0, 0, 1]]
    : let(uv=unit_vector(v))
    cos(a)*identity(3) + sin(a)*skew_symmetric(uv) + (1 - cos(a))*tensor_product1(uv);


 /*echo(rotate(90, X) * [1, 0, 0]);*/
 /*echo(rotate(90, X) * [0, 1, 0]);*/
 /*echo(rotate(90, X) * [0, 0, 1]);*/

function lerp(v0, v1, t) =  (1-t)*v0 + t*v1;

if($test_mode)
{
    assert(lerp(-1, 1, 0) == -1);
    assert(lerp(-1, 1, .5) == 0);
    assert(lerp(-1, 1, 1) == 1);
}

if($test_mode)
{
    assert_v(fallback(U,1), 1);
}

function fallback(a, b) = a==U?b:a;

// echo(fallback(U,[U, 1]));
function v_fallback(a,v,i=0) = (a!=U || i > len(v)-1) ? a : v_fallback(v[i],v,i+1);

function zip(a,b,start=0,end) = [for(i=[start:1:fallback(end,len(a)-1)]) [a[i],b[i]] ];
function zip_v(v,start=0,end) = [for(i=[start:1:fallback(end,len(v[0])-1)]) v_i(v,i) ];

if($test_mode)
{
    vec_a = [0,4];
    vec_b = [1,5];
    vec_c = [2,6];
    vec_d = [3,7];
    assert_v(zip(vec_a,vec_b),[[0,1],[4,5]]);
    assert_v(zip_v([vec_a,vec_b]),[[0,1],[4,5]]);
    assert_v(zip_v([vec_a,vec_b,vec_c,vec_d]), [[0,1,2,3],[4,5,6,7]]);
}

function vv_fallback(v,start=0,end) =
let(z = zip_v(v))
[
for(i=[start:1:fallback(end,len(v[0])-1)])
    v_fallback(v=z[i],i=0)
];

if($test_mode)
{
    vec_a=[ 10,  U,   U, 40 ];
    vec_b=[ 10,  U,  30,  U ];
    vec_c=[  U, 20,   U, 40 ];
    assert(v_fallback(a=5, v=vec_a), 5);
    assert_v(vv_fallback(v=[vec_a, vec_b,vec_c]), [10,20,30,40]);
}

function fn_from_r(r) =
                    $fn > 0.0 ?
                    ($fn >= 3 ? $fn : 3)
                    :
                    ceil(max(min(360.0 / $fa, r*2*PI / $fs), 5));

function fn_from_d(d) =
                    $fn > 0.0 ?
                    ($fn >= 3 ? $fn : 3)
                    :
                    ceil(max(min(360.0 / $fa, d*PI / $fs), 5));

module assert_v(val, expected, message)
{
    if(len(val) > 0)
    {
        if(len(val) != len(expected))
        {
            echo("assertion, not equal length of arrays", val, expected);
            assert(val == expected, message);
        }
        for(i=[0:len(val)])
        {
            if(val[i] != expected[i])
            {
                echo("assertion, unexpected value at index", i, val, expected);
                assert(val == expected, message);
            }
        }

    }
    else
    {
        if(val != expected)
        {
            echo("assertion, unexpected value", val, expected);
            assert(val == expected, message);
        }
    }
}

function spread(v0,v1,a) =
a>=2 ?
    [for(i=[0:1/(a-1):1]) lerp(v0,v1,i)]
:
    [lerp(v0,v1,.5)]
;

if($test_mode)
{
    assert_v(spread(-1, 1, 1), [0]);
    assert_v(spread(-1, 1, 2), [-1,1]);
    assert_v(spread(-1, 1, 3), [-1,0,1]);
    // fails because of float inaccuracy
    /*assert_v(spread(-1, 1, 4), [-1,-1/3,1/3,1]);*/
    assert_v(spread(-1, 1, 5), [-1,-.5,0,.5,1]);
}

// the apothem (inradius) is the distance from the center of a regular
// polygon to the flat side (not a vertex)
function apothem(circumradius, fn) = circumradius*cos(180/fn);
function inradius(circumradius, fn) = circumradius*cos(180/fn);;
// the circumradius (outradius) is the distance from the center of a regular
// polygon to a vertex
function circumradius(apothem, fn) = apothem / cos(180/fn);
function outradius(apothem, fn) = apothem / cos(180/fn);
function fn_radius(r, fn) = apothem(r,fn);
function hex_radius(r) = apothem(r, 6);


if($test_mode)
{
    assert_v(apothem(circumradius(5,6)), circumradius(apothem(5),6));
}

function header_col_index(v, col_keys) = 
    singlify(
        [for(col_key=col_keys)
        let(result=search([col_key], v[0], index_col_number=0, num_returns_per_match=0))
        result[0][0]
        ]
    );

function geth(S, col_keys, row_index) = 
    singlify(
        [for(col_key=col_keys)
            let(col_index = header_col_index(S, col_key))
            S[row_index+1][col_index]
        ]);

if($test_mode)
{
    A = [
    ["Tx", "Ty"],
    [1, 2],
    [3, 4],
    ];

    assert_v(header_col_index(A, "Tx"), 0);
    assert_v(header_col_index(A, "Ty"), 1);

    assert_v(header_col_index(A, ["Ty"]), 1);
    assert_v(header_col_index(A, ["Tx"]), 0);
    assert_v(header_col_index(A, ["Tx", "Ty"]), [0,1]);

    assert_v(geth(A, "Tx", 0), 1);
    assert_v(geth(A, "Tx", 1), 3);
    assert_v(geth(A, "Ty", 0), 2);
    assert_v(geth(A, "Ty", 1), 4);

    assert_v(geth(A, ["Tx","Ty"], 0), [1,2]);
    assert_v(geth(A, ["Tx","Ty"], 1), [3,4]);

}

function v_contains(V, val, start=0, end=U) =
    !is_array(V) ?
        V == val :
        let(e=end==U?len(V):end)
        V[start]==val ? true :
        start == len(V)-1 ? false :
        v_contains(V,val,start+1,end);

if($test_mode)
{
    assert_v(v_contains(0, 0), true);
    assert_v(v_contains(0, 1), false);
    assert_v(v_contains([0,1], 0), true);
    assert_v(v_contains([0,1], 1), true);
    assert_v(v_contains([0,1], 2), false);
}

// helper functions to work on headered-arrays (where first entry is column headers)
function reverse_header(V) = concat([V[0]], reverse(v_slice(V,start=1)));
function concat_header(A,B) =concat([A[0]], v_slice(A,start=1),v_slice(B,start=1));

// add value from these columns in headered array
function array_header_col_add(S, cols, val) =
    let(cols = header_col_index(S,cols))
    concat([S[0]],
    [
        for(i=[1:len(S)-1])
        [
        for(j=[0:len(S[0])-1])
            (v_contains(cols,j)) ?
                S[i][j] + val :
                S[i][j]
        ]
    ]);

function array_header_col_subtract(S, cols, val) = array_header_col_add(S,cols,-val);

if($test_mode)
{
    A = [
    ["Tx", "Ty"],
    [1, 2],
    [3, 4],
    ];

    assert_v(
        array_header_col_add(A, "Tx", -1),
        [["Tx","Ty"],
         [0,2],
         [2,4],
        ]);

    assert_v(
        array_header_col_add(A, ["Tx"], -1),
        [["Tx","Ty"],
         [0,2],
         [2,4],
        ]);

    assert_v(
        array_header_col_add(A, ["Tx","Ty"], -1),
        [["Tx","Ty"],
         [0,1],
         [2,3],
        ]);

    assert_v(
        array_header_col_add(A, ["Ty"], -1),
        [["Tx","Ty"],
         [1,1],
         [3,3],
        ]);
}


function take3(v) = [v[0],v[1],v[2]];

function vec3(V) =
let(l = len(V))
l == 3 ? V :
l < 3 ? vec3(concat(V,0)) :
take3(V);

if($test_mode)
{
    assert_v(take3([0,1,0,1]), [0,1,0]);

    assert_v(vec3([0,1]), [0,1,0]);
    assert_v(vec3([0]), [0,0,0]);
    assert_v(vec3([1]), [1,0,0]);
    assert_v(vec3([0,0,1]), [0,0,1]);
    assert_v(vec3([0,0,1,0]), [0,0,1]);
}

