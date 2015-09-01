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
function v_sum(v, i) = i >= 0 ? v[i] + sum_vec(v, i - 1) : 0;

// filter/remove a val from a vec
function filter(vec,val=undef) = [for(v=vec) if(v!=val) v];

function vec_pair_double_transform_post(vec,t1,t2)=
    flatten(
        [for(v=vec)
            [transform_post(v,t1),transform_post(v,t2)]
        ]);

function vec_pair_double(vec)=flatten([for(v=vec) [v,v] ]);
