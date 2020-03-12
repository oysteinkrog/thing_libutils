include <system.scad>
use <misc.scad>
use <transforms.scad>;
use <shapes.scad>

// From Obiscad,
// modified to take roll parameter as param in module instead of attachment points
//-------------------------------------------------------------------------
// ATTACH OPERATOR
// This operator applies the necessary transformations to the
// child (attachable part) so that it is attached to the main part
// Parameters
//  a: Connector of the main part
//  b: Connector of the attachable part
//  explode: extra translation between parts (child moved away from parent)
//  roll:
//  rollaxis:
//-------------------------------------------------------------------------
module attach(a, b, roll=0, rollaxis=N)
{
    /*if($debug)*/
    /*echo("attach():", a,b,roll,rollaxis);*/

    assert(is_list(a), a);
    assert(len(a)==2, a);
    assert_v3n(a[0], a);
    assert_v3n(a[1], a);
    /*assert(a[1]!=N, a);*/

    assert(is_list(b), b);
    assert(len(b)==2, b);
    assert_v3n(b[0], b);
    assert_v3n(b[1], b);
    /*assert(b[1]!=N, b);*/

    assert(is_num(roll));

    // Get the data from the connectors
    // Attachment point. Main part
    pos1 = a[0];
    // Attachment axis. Main part
    v    = a[1];

    // Attachment point. Attachable part
    pos2 = b[0];
    // Atachment axis. Attachable part
    vref = b[1];

    assert(is_list(pos1));
    assert(is_list(v));
    assert(is_list(pos2));
    assert(is_list(vref));

    // Calculations for the "orientate operator"
    // Calculate the rotation axis
    raxis = v_cross(vref,v);

    // Calculate the angle between the vectors
    // this can become nan if vref and v are N
    ang_ = v_anglev(vref,v);
    ang = is_num(ang_)?ang_:0;
    assert(is_num(ang));

    raxis_=ang==180&&raxis==N?X:raxis;

    /*if($debug)*/
    /*echo(pos1,v,pos2,vref, raxis, ang, raxis_);*/

    // Apply the transformations to the child

    // Place the attachable part on the main part attachment point
    t(pos1)
    // Orientate operator. Apply the orientation so that
    // both attachment axis are paralell. Also apply the roll angle
    r(a=roll, v=rollaxis)
    r(a=ang, v=raxis_)
    // Attachable part to the origin
    t(-pos2)
    t(is_undef($explode)?[0,0,0]:-$explode*vref)
    {
        children();

        if(is_undef($show_conn)?false:$show_conn)
        connector([b.x, -b.y]);
    }

    if(is_undef($show_conn)?false:$show_conn)
    connector(a);
}

if(false)
{
    s=[10,10,10];

    conn = [X*s.x/2,X];

    /*connector(conn);*/
    cubea(s);
    attach(conn, -conn, $explode=2)
    spherea(d=s.x);
}

