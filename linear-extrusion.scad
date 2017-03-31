include <system.scad>
include <units.scad>

use <shapes.scad>
use <transforms.scad>

module linear_extrusion(h=10, center=true, align=N, orient=Z)
{
    size_align(size=[20,20,h], align=align, orient=orient, orient_ref=Z)
    {
        if($preview_mode)
        {
            cubea([20, 20, h]);
        }
        else
        {
            linear_extrude(height = h, center = true, convexity = 10, twist = 0)
            {
                import (file = "data/misumi-extrusion/hfs5-2020-profile.dxf");
            }
        }
    }
}

if(false)
{
    all_axes()
    color($color)
    translate(10*$axis)
    linear_extrusion(h=100, align=$axis, orient=$axis);
}
