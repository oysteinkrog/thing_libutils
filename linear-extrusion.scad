use <shapes.scad>

module linear_extrusion(h=10, center=true, align=[0,0,0], orient=[0,0,1])
{
    size_align([20,20,h], align, orient)
    {
        linear_extrude(height = h, center = true, convexity = 10, twist = 0)
        {
            import (file = "data/misumi-extrusion/hfs5-2020-profile.dxf");
        }
    }
}

linear_extrusion(h=100, align=[0,0,0], orient=[0,0,1]);


