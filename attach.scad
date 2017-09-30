include <system.scad>
use <misc.scad>
use <transforms.scad>;
use <shapes.scad>

// From Obiscad,
// modified to take roll parameter as param in module instead of attachment points
//-------------------------------------------------------------------------
//--  ATTACH OPERATOR
//--  This operator applies the necesary transformations to the 
//--  child (attachable part) so that it is attached to the main part
//--  
//--  Parameters
//--    a -> Connector of the main part
//--    b -> Connector of the attachable part
//-------------------------------------------------------------------------
module attach(a, b, roll=0, rollaxis)
{
    //-- Get the data from the connectors
    pos1 = a[0];  //-- Attachment point. Main part
    v    = a[1];  //-- Attachment axis. Main part

    pos2 = b[0];  //-- Attachment point. Attachable part
    vref = b[1];  //-- Atachment axis. Attachable part

    //-------- Calculations for the "orientate operator"------
    //-- Calculate the rotation axis
    raxis = v_cross(vref,v);

    //-- Calculate the angle between the vectors
    ang = v_anglev(vref,v);
    //--------------------------------------------------------.-

    raxis_=ang==180&&raxis==N?X:raxis;

    //-- Apply the transformations to the child ---------------------------

    //-- Place the attachable part on the main part attachment point
    translate(pos1)
        //-- Orientate operator. Apply the orientation so that
        //-- both attachment axis are paralell. Also apply the roll angle
        rotate(a=roll, v=rollaxis==U?v:rollaxis)  rotate(a=ang, v=raxis_)
        //-- Attachable part to the origin
        translate(-pos2)
        children();
}

