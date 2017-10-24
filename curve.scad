include <system.scad>
use <shapes.scad>
use <scad-utils/lists.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/linalg.scad>
use <scad-utils/se3.scad>
use <scad-utils/so3.scad>
use <list-comprehension-demos/skin.scad>
use <list-comprehension-demos/sweep.scad>


module draw_path(path, r=1) {
    for (i=[0:len(path)-2]) {
        hull() {
            translate(path[i]) sphere(r);
            translate(path[i+1]) sphere(r);
        }
    }
}

module draw_transform(transform, r=1) {
    multmatrix(transform) scale(r/3) frame(10);
}

module draw_transforms(transforms, r=1) {
    for (t=transforms) {
        draw_transform(t,r);
    }
}

function vec_trans(path_t) = [for(t=path_t) translation_part(t)];

function to_delta_trans(path)=
[
    let(l=len(path))
    for (i=[0:l-1-1])
        trajectory(translation=path[i+1]-path[i])
];

function quantize_path(path, step, includestartoffset=1) = let (
    // construct vector of delta translations
    path_traj = to_delta_trans(path)
    // quantize evenly along path
    , path_q_f = quantize_trajectories(path_traj, step=step, loop=false, start_position=0)
    )
    includestartoffset == 1 ?
        [for(v=path_q_f) path[0]+translation_part(v)]
        :
        [for(v=path_q_f) translation_part(v)]
;

function step_vec(vec, step, start_offset=0, end_offset=0) =
    [start_offset:step:len(vec)-1-end_offset];

function iterate_step_vec(vec, step, start_offset=0, end_offset=0, even=0) =
    even==1?
    //remainder
    let(r = (len(vec)-1) % step)
    [for(k=[r/2+start_offset:step:len(vec)-1-end_offset]) vec[k]]
    :
    [for(k=[start_offset:step:len(vec)-1-end_offset]) vec[k]]
;

module place(vec_t, debug=0)
{
    for(t=vec_t)
    {
        multmatrix(t)
        {
            if(debug>=1)
            {
                {
                    draw_transforms(t);
                }
            }
            children();
        }
    }
}

module placealong(vec_t, step, start_offset=0, end_offset=0, even=0, debug=0)
{
    vec = iterate_step_vec(vec_t,step,start_offset,end_offset, even);
    place(vec, debug)
    {
        children();
    }
}

function c(t, r=[20,20], degrees=360) = [
    r[0]*(cos((degrees)*t)),
    0,
    r[1]*(sin((degrees)*t)),
];
function c_(t, r=[20,20], degrees=360) = [
    r[0]*-degrees*(sin((degrees)*t)),
    0,
    r[1]*-degrees*(cos((degrees)*t)),
];

function f(t,r,d)=c(t,r,d)-c(0,r,d);

/*s = degrees/4;*/
s = 10;

degrees = s*10;

// one step per degree
degstep = 1;
path_e = [for (t=[0:degstep/degrees:1-degstep/degrees]) vec3(f(t,[80,50],degrees)) ];

// normal transform path (not evenly distributed points)
path_t = construct_transform_path(path_e);

// evenly distributed points, "acc" steps per degree
acc = 2;
path_e_q = quantize_path(path_e, step=1/acc);
path_t_q = construct_transform_path(path_e_q);
/*accstep = acc * len(path_t)/len(path_t_q);*/

function path_sweepalong(path) = [for(k=path) place_mat()*k];
function path_placealong(path) = [for(k=path) place_mat()*k*rotation([180,90,0])];

function place_mat() =
    translation(N)
    *
    rotation(N)
    ;

shape_debug = rectangle_profile([0.5,0.5]);


// non-interpolated
translate(N)
{
    color("black")
    {
        sweep(shape_debug, path_sweepalong(path_t), false);
    }
    placealong(path_placealong(path_t), s, even=0, debug=1)
    {
        color("red")
        {
            cube([s,5,0.1], true);
        }
    }
}

// interpolated
translate([0,10,0])
{
    color("black")
    {
        sweep(shape_debug, path_sweepalong(path_t_q), false);
    }
    placealong(path_placealong(path_t_q), s*acc, even=0, debug=1)
    {
        color("blue")
        {
            cube([s,5,0.1], true);
        }
    }
}

