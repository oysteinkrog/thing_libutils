/*include <../scad-utils/transformations.scad>*/

include <system.scad>
use <misc.scad>

module t(dist)
{
    assert(dist!=U, "t(): dist==U");
    assert(is_list(dist), dist);
    assert(len(dist)==3, "t(): len(dist)!=3");
    translate(dist)
    children();
}

module tx(dist)
{
    assert(dist!=U, "tx(): dist==U");
    assert(is_num(dist), "tx(): dist is not a number");
    translate(X*dist)
    children();
}

module ty(dist)
{
    assert(dist!=U, "ty(): dist==U");
    assert(is_num(dist), "ty(): dist is not a number");
    translate(Y*dist)
    children();
}

module tz(dist)
{
    assert(dist!=U, "tz(): dist==U");
    assert(is_num(dist), "tz(): dist is not a number");
    translate(Z*dist)
    children();
}

module txy(off)
{
    assert(off!=U, "txy(): off==U");
    assert(len(off)==3, "txy(): len(off)!=3");
    tx(off.x)
    ty(off.y)
    children();
}

module txz(off)
{
    assert(off!=U, "txz(): off==U");
    assert(len(off)==3, "txz(): len(off)!=3");
    tx(off.x)
    tz(off.z)
    children();
}

module tyz(off)
{
    assert(off!=U, "tyz(): off==U");
    assert(len(off)==3, "tyz(): len(off)!=3");
    ty(off.y)
    tz(off.z)
    children();
}

module r(a, v)
{
    if(is_list(a))
    {
        assert(is_undef(v), v);
        assert_v3n(a);
        rotate(a)
        children();
    }
    else
    {
        assert(is_num(a), a);
        assert_v3n(v);
        rotate(a,v)
        children();
    }
}

module rx(degrees)
{
    rotate(X*degrees)
    children();
}

module ry(degrees)
{
    rotate(Y*degrees)
    children();
}

module rz(degrees)
{
    rotate(Z*degrees)
    children();
}

module mx(m=true)
{
    assert(is_bool(m));
    mirror(X*m)
    children();
}

module my(m=true)
{
    assert(is_bool(m));
    mirror(Y*m)
    children();
}

module mz(m=true)
{
    assert(is_bool(m));
    mirror(Z*m)
    children();
}


// translate children
module position(positions)
{
    assert(positions!=U, "positions==U");
    for(pos=positions)
    translate(pos)
    children();
}

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

module spread(axis=N, dist=0, iter=[-1,1])
{
    assert(is_list(axis));
    assert(is_num(dist));
    assert(is_list(iter));

    for(i=iter)
    translate(i*axis*dist)
    children();
}

module spreadx(dist=0)
{
    spread(axis=X,dist=dist)
    children();
}

module spready(dist=0)
{
    spread(axis=Y,dist=dist)
    children();
}

module spreadz(dist=0)
{
    spread(axis=Z,dist=dist)
    children();
}

module orient(axis=U, axis_ref=U, roll=0, extra_roll, extra_roll_orient)
{
    rotate(extra_roll_orient==U||extra_roll==U?0:extra_roll*extra_roll_orient)

    // orient to reference axis
    /*rotate(axis_ref==U?0:_orient_angles(axis_ref))*/
    /*multmatrix(axis_ref==U?0:v_rotate(90, axis_ref))*/
    rotate(axis_ref==U?0:_orient_angles(axis_ref))

    // roll around orient axis
    rotate(axis==U?0:roll*axis)

    // orient to axis
    /*multmatrix(axis==U?0:v_rotate(90, axis))*/
    rotate(axis==U?0:_orient_angles(axis))
    children();
}

module orient_(axis=U, axis_ref=U, roll=0, extra_roll, extra_roll_orient)
{
    rotate(extra_roll_orient==U||extra_roll==U?0:extra_roll*extra_roll_orient)

    // orient to reference axis
    multmatrix(axis_ref==U?0:v_rotate(90, axis_ref))

    // roll around orient axis
    rotate(axis==U?0:roll*axis)

    // orient to axis
    multmatrix(axis_ref==U?0:v_rotate(90, axis))
    children();
}

function _orient_bounds(orient, size) =
    (_rotate_matrix(_orient_angles(orient)) * [size.x,size.y,size.z,1]);

function _orient_t(orient, align, size) =
    let(bounds = _orient_bounds(orient, size))
    (hadamard(align, [abs(bounds.x/2),abs(bounds.y/2),abs(bounds.z/2)]));

module size_align(size=[10,10,10], extra_size=N, align=N, extra_align=N, orient=Z, orient_ref=Z, roll=0, extra_roll, extra_roll_orient)
{
    assert(orient != N);
    assert_v3n(align);
    assert_v3n(orient);
    assert_v3n(size);
    t = orient==U?N:_orient_t(orient, align, size);
    extra_t = (orient==U||extra_size==U||extra_size==[U,U,U]||extra_size==[0,0,0]||extra_align==U) ?
        N : _orient_t(orient, extra_align, extra_size);
    assert_v3n(t);
    assert_v3n(extra_t);
    /*assert(extra_t[0] < 0 && extra_t[0] == 0 && extra_t[0] > 0 || extra_t[);*/
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

module proj_extrude_axis(axis=Z, h=1, offset=0, cut=false)
{
    translate(-offset*axis)
    hull()
    {
        orient_(axis=axis, axis_ref=Z)
        {
            linear_extrude(h, center=false)
            projection(cut=cut)
            orient_(axis=Z, axis_ref=axis)
            translate(offset*axis)
            children();

            orient_(axis=Z, axis_ref=axis)
            translate(offset*axis)
            children();
        }
    }
}

module all_axes()
{
    for($axis=concat(AXES,-AXES))
    {
        $color = v_abs($axis*.3 + v_clamp(v_sign($axis),0,1)*.7);
        children();
    }
}

// test proj_extruder_axis
if(false)
{
    all_axes()
    color($color)
    translate(5*$axis)
    proj_extrude_axis(axis=$axis)
    translate(20*$axis)
    sphere(d=10);
}

if(false)
{
    translate(Y*10)
    proj_extrude_axis(axis=Y, offset=10)
    {
        sphere(d=10);
    }
}

module proj_extrude_axis_part(axis=Z, h=1, offset=0, cut=false)
{
    translate(-offset*axis)
    {
        orient_(axis=axis, axis_ref=Z)
        {
            hull()
            linear_extrude(offset, center=false)
            projection(cut=cut)
            orient_(axis=Z, axis_ref=axis)
            translate(offset*axis)
            children();

            orient_(axis=Z, axis_ref=axis)
            translate(offset*axis)
            children();
        }
    }
}

if(false)
{
    tz(10)
    proj_extrude_axis_part(axis=Z, offset=10)
    {
        x = 15;
        cylinder(d=5, h=20);

        tx(x)
        cylinder(d=5, h=20);
    }
}

// translate by pos, with extra (depending on the sign of pos)
// an "explode" function
module te(pos, extra=[0,0,0])
{
    assert(len(pos) == 3);
    assert(len(extra) == 3);

    t(pos + v_mul(extra , v_sign(pos)))
    children();
}

