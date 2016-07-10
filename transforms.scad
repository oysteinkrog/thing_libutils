use <misc.scad>

// translate children
module linup(arr=undef)
{
    if($children>0)
    {
        for (i = [0 : $children-1])
        translate(arr[i]) children(i);
    }
}

module stack(dist=10, distances=undef, axis=[0,0,1])
{
    if($children>0)
    {
        if(dist == undef && distances != undef)
        {
            for (i = [0:len(distances)-1])
            {
                offset = v_sum(distances,i);
                translate(axis*offset)
                    child(i);
            }
        }
        else if(dist != undef && distances == undef)
        {
            for (i = [0 : $children-1])
                translate(axis*(dist*i))
                    children(i);
        }
    }
}

module orient(zaxes, roll=0)
{
    zaxes = len(zaxes.x) == undef && zaxes.x != undef? [zaxes] : zaxes;
    for(zaxis=zaxes)
    {
        rotate(_orient_angles(zaxis))
        /*rotate(roll*z)*/
            children();
    }
}

function _orient_bounds(orient, size) =
    (_rotate_matrix(_orient_angles(orient)) * [size.x,size.y,size.z,1]);

function _orient_t(orient, align, size) =
    let(bounds = _orient_bounds(orient, size))
    (hadamard(align, [abs(bounds.x/2),abs(bounds.y/2),abs(bounds.z/2)]));

module size_align(size=[10,10,10], align=[0,0,0], orient=[0,0,1])
{
    t = _orient_t(orient, align, size);
    translate(t)
    {
        orient(orient)
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

