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
module attach(a, b, roll=0, rollaxis)
{
    // Get the data from the connectors
    // Attachment point. Main part
    pos1 = a[0];
    // Attachment axis. Main part
    v    = a[1];

    // Attachment point. Attachable part
    pos2 = b[0];
    // Atachment axis. Attachable part
    vref = b[1];

    // Calculations for the "orientate operator"
    // Calculate the rotation axis
    raxis = v_cross(vref,v);

    // Calculate the angle between the vectors
    ang = v_anglev(vref,v);

    raxis_=ang==180&&raxis==N?X:raxis;

    // Apply the transformations to the child

    // Place the attachable part on the main part attachment point
    t(pos1)
    // Orientate operator. Apply the orientation so that
    // both attachment axis are paralell. Also apply the roll angle
    r(a=roll, v=rollaxis==U?v:rollaxis)
    r(a=ang, v=raxis_)
    // Attachable part to the origin
    t(-pos2)
    t(-$explode==U?0:$explode*vref)
    {
        children();

        if($show_conn)
        connector([b.x, -b.y]);
    }

    if($show_conn)
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

