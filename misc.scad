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

function vec_add(vec,v) = [for(vv=vec) vv+v];

function v_itrlen(vec) = [0:1:len(vec)-1];

function range1(v1) = [min(v1), max(v1)];
function range3(v3) = [range1(vec_0(v3)), range1(vec_1(v3)), range1(vec_2(v3))];
function bbox(r) = [ [r[0][0],r[1][0],r[2][0]], [r[0][1],r[1][1],r[2][1]] ];
function transform_pp(vec_m, t_pre, t_post) = [for(m=vec_m) (t_pre*m)*t_post];
function transform_pre(vec_m, t) = [for(m=vec_m) t*m];
function transform_post(vec_m, t) = [for(m=vec_m) m*t];

function clamp(v, v1, v2) = min(max(v,v1),v2);

// from the start (or s'th element) to the e'th element - remember elements are zero based
function v_sum(v,e=undef,start=0) = 
let(e_= e==undef ? len(v)-1 : e)
(e==start ? v[e] : v[e_] + v_sum(v,e_-1,start));

function v_abs(v, start=0) = [for(i=[start:1:len(v)-1]) abs(v[i])];
function v_sign(v, start=0) = [for(i=[start:1:len(v)-1]) sign(v[i])];
function v_max(v, m, start=0) = [for(i=[start:1:len(v)-1]) max(v[i],m)];
function v_min(v, m, start=0) = [for(i=[start:1:len(v)-1]) min(v[i],m)];
function v_clamp(v, v1, v2, start=0) = [for(i=[start:1:len(v)-1]) clamp(v[i],v1,v2)];

// cumulative sum of vector [1,2,3] = [1,3,6]
function v_cumsum(v, start=0) = [for(i=[start:1:len(v)-1]) v_sum(v,i)];

// filter/remove a val from a vec
function filter(vec,val=undef) = [for(v=vec) if(v!=val) v];

function vec_pair_double_transform_post(vec,t1,t2)=
    flatten(
        [for(v=vec)
            [transform_post(v,t1),transform_post(v,t2)]
        ]);

function vec_pair_double(vec)=flatten([for(v=vec) [v,v] ]);

/** Calculates length of hypotenuse according to pythagoras */
function pythag_hyp(a, b)=sqrt(a*a+b*b);
function pythag_leg(b, c)=sqrt(c*c-b*b);


//-- Calculate the module of a vector
function v_mod(v) = (sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]));

//-- Calculate the cros product of two vectors
function v_cross(u,v) = [
  u[1]*v[2] - v[1]*u[2],
  -(u[0]*v[2] - v[0]*u[2]) ,
  u[0]*v[1] - v[0]*u[1]];

//-- Calculate the dot product of two vectors
function v_dot(u,v) = u[0]*v[0]+u[1]*v[1]+u[2]*v[2];

//-- Return the unit vector of a vector
function v_unitv(v) = v/v_mod(v);

//-- Return the angle between two vectores
function v_anglev(u,v) = acos( v_dot(u,v) / (v_mod(u)*v_mod(v)) );

function _orient_angles(zaxis)=
[-asin(zaxis.y / norm(zaxis)),
    atan2(zaxis.x, zaxis.z),
    0];

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
	x == undef || len(x) == undef
		? false // if undef, a boolean or a number
		: len(str(x,x)) == len(x)*2; // if an array, this is false

// FUNCTION: is_array(x)
//   Returns true if x is an array, false otherwise.
function is_array(x) = is_string(x) ? false : len(x) != undef;

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


 /*echo(rotate(90, [1,0,0]) * [1, 0, 0]);*/
 /*echo(rotate(90, [1,0,0]) * [0, 1, 0]);*/
 /*echo(rotate(90, [1,0,0]) * [0, 0, 1]);*/

function lerp(v0, v1, t) =  (1-t)*v0 + t*v1;
