use <shapes.scad>
use <transforms.scad>

module linear_extrusion(h=10, center=true, align=N, orient=Z)
{
    size_align(size=[20,20,h], align=align, orient=orient, orient_ref=Z)
    {
        linear_extrude(height = h, center = true, convexity = 10, twist = 0)
        {
            import (file = "data/misumi-extrusion/hfs5-2020-profile.dxf");
        }
    }
}

/*include <system.scad>*/
/*include <units.scad>*/
/*include <misc.scad>*/
/*for(axis=concat(AXES,-AXES))*/
/*translate(axis*20/2)*/
/*{*/
    /*c= v_abs(axis*.3 + v_clamp(v_sign(axis),0,1)*.7);*/
    /*color(c)*/
        /*linear_extrusion(h=100, align=axis, orient=axis);*/
/*}*/
