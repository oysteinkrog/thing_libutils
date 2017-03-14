include <system.scad>
use <misc.scad>

// translate children
module linup(arr=U)
{
    if($children>0)
    {
        for (i = [0 : $children-1])
        translate(arr[i]) children(i);
    }
}

module stack(dist=10, distances=U, axis=Z)
{
    if($children>0)
    {
        if(dist == U && distances != U)
        {
            for (i = [0:len(distances)-1])
            {
                offset = v_sum(distances,i);
                translate(axis*offset)
                    child(i);
            }
        }
        else if(dist != U && distances == U)
        {
            for (i = [0 : $children-1])
                translate(axis*(dist*i))
                    children(i);
        }
    }
}

module orient_(axis=Z, roll=0)
{
    rotate(axis==U?0:roll*axis)
    rotate(axis==U?0:_orient_angles(axis))
    children();
}

module orient(axis=Z, axis_ref=Z, roll=0, extra_roll, extra_roll_orient)
{
    rotate(extra_roll_orient==U||extra_roll==U?0:extra_roll*extra_roll_orient)

    // orient to reference axis
    rotate(axis_ref==U?0:_orient_angles(axis_ref))

    // roll around orient axis
    rotate(axis==U?0:roll*axis)

    // orient to axis
    rotate(axis==U?0:_orient_angles(axis))
    children();
}


function _orient_bounds(orient, size) =
    (_rotate_matrix(_orient_angles(orient)) * [size.x,size.y,size.z,1]);

function _orient_t(orient, align, size) =
    let(bounds = _orient_bounds(orient, size))
    (hadamard(align, [abs(bounds.x/2),abs(bounds.y/2),abs(bounds.z/2)]));

module size_align(size=[10,10,10], extra_size=N, align=N, extra_align=N, orient=Z, orient_ref=Z, roll=0, extra_roll, extra_roll_orient)
{
    t = orient==U?N:_orient_t(orient, align, size);
    /*t_ = orient_ref==U?N:_orient_t(orient_ref, align, size);*/
    extra_t = (orient==U||extra_size==U)?N:_orient_t(orient, extra_align, extra_size);
    translate(t+extra_t)
    {
        orient(axis=orient, axis_ref=orient_ref, roll=roll, extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
        {
            children();
        }
    }
}

module hull_pairwise()
{
    for (i= [1:1:$children-1])
    {
        hull()
        {
            children(i-1);
            children(i);
        }
    }
}

