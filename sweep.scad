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
use <list-comprehension-demos/draw-helpers.scad>


function combine_accumulated_rotations(a,b) =
concat(a, [ let(e = a[len(a)-1]) for(t = b) t * e ]);

function accumulate_rotations(rotations) = let(N=len(rotations))
    N == 0 ? [] :
    N == 1 ? rotations :
    let(mid = floor(N/2))
    combine_accumulated_rotations(
            accumulate_rotations(subarray(rotations,0,mid)),
            accumulate_rotations(subarray(rotations,mid))
            );

function construct_torsion_minimizing_rotations(tangents) = [
    for (i = [0:len(tangents)-2])
        rotate_from_to(tangents[i],tangents[i+1])
];

// Calculates the relative torsion along the Z axis for two transformations
function calculate_twist(A,B) = let(D = transpose_3(B) * A)
                                    atan2(D[1][0], D[0][0]);

function construct_transform_path_mod(path, closed=false) = let(
        l = len(path),
        tangents = [ for (i=[0:l-1]) tangent_path(path, i)],
        local_rotations = construct_torsion_minimizing_rotations(concat([[0,0,1]],tangents)),
        rotations = accumulate_rotations(local_rotations),
        twist = closed ? calculate_twist(rotations[0], rotations[l-1]) : 0
        )  [ for (i = [0:l-1]) construct_rt(rotations[i], path[i]) * rotation([0,0,twist*i/(l-1)])];

function path_extend(path, extend=[5,5]) =
    let(
        path_start = path[0],
        path_end = path[len(path)-1],

        path_start_e_ = path_start * translation([0,0,-extend[0]]),
        path_end_e_ = path_end * translation([0,0,extend[1]]),

        s_t1 = translation_part(path_start),
        s_t2 = translation_part(path_start_e_),
        s_t3 = [s_t2[0],s_t2[1],s_t1[2]],

        e_t1 = translation_part(path_end),
        e_t2 = translation_part(path_end_e_),
        e_t3 = [e_t2[0],e_t2[1],e_t1[2]],

        path_start_e = construct_rt(rotation_part(path_start_e_), s_t3),
        path_end_e = construct_rt(rotation_part(path_end_e_), e_t3)
       )

    // extended path
    concat([path_start_e], path, [path_end_e]);

use <misc.scad>
module sweep_t(shape, path_transforms, closed=false, t_pre=identity4(), t_post=identity4())
{
    /*path_transforms_mod = path_transforms;*/
    path_transforms_mod =
        t_pre==undef?
        t_post==undef?
        path_transforms
        : transform_post(path_transforms, t_post)
        :
        t_post==undef?
        transform_pre(path_transforms, t_pre)
        : transform_pp(path_transforms, t_pre, t_post)
        ;

    sweep(shape, path_transforms_mod, closed);
}

function path_size_i(path,i) =
    let(
            path_t_i=[for(t=path) translation_part(t)[i]]
       )
    max(path_t_i)-min(path_t_i);

function path_size(path) =
    [
        path_size_i(path,0), path_size_i(path,1), path_size_i(path,2),
    ];

