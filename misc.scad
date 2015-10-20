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

// sum a vector up to position i
function v_sum(v, i) = i >= 0 ? v[i] + v_sum(v, i - 1) : 0;

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
