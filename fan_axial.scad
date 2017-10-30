// Remixed from MiseryBot's original work: http://www.thingiverse.com/thing:8063
include <system.scad>
include <units.scad>
include <shapes.scad>
include <transforms.scad>
include <screws.scad>
include <MCAD/boxes.scad>

module axialfan(width, depth, mount_dist, thread, head_embed=true, corner_radius=3, blade_angle=-45, bore_dia_walls=1.5, orient=Z, align=N)
{
    s = [width, width, depth];
    size_align(size=s, orient=orient, orient_ref=-Z, align=align)
    {
        bore_diameter = width - bore_dia_walls;
        s = [width, width, depth];
        difference()
        {
            union()
            {
                roundedBox(size=s, radius=corner_radius, sidesonly=true);
            }

            difference()
            {
                cylindera(d=bore_diameter, h=depth+.2, orient=Z);
                cylindera(d=bore_diameter/2 + 2*mm, h=depth+.2, orient=Z);
            }

            for(x=[-1,1])
            for(y=[-1,1])
            translate([x*mount_dist/2, y*mount_dist/2, depth/2])
            {
                screw_cut(thread=thread, h=depth, head_embed=head_embed, orient=-Z, align=-Z);
            }
        }
        axialfan_blades(width=bore_diameter, depth=depth, blade_angle=blade_angle);
    }
}


module axialfan_cut(width, depth, tolerance=.3*mm, mount_dist, screw_l, thread, head_embed=true, orient=Z, align=N)
{
    s = [width, width, depth];
    size_align(size=s, orient=orient, orient_ref=-Z, align=align)
    {
        cubea(size=s, extrasize=[tolerance,tolerance,tolerance]);

        for(x=[-1,1])
        for(y=[-1,1])
        translate([x*mount_dist/2, y*mount_dist/2, depth/2])
        {
            screw_cut(thread=thread, h=screw_l, head_embed=head_embed, orient=-Z, align=-Z);
        }
    }
}

module body(width, depth, bore_diameter, mount_dist, corner_radius, thread)
{

}

module axialfan_blades(width, depth, angle)
{
    linear_extrude(height=depth-1, center = true, convexity = 4, twist = angle)
    {
        for(i=[0:6])
        rotate((360*i)/7)
        translate([0,-1.5/2]) square([width/2-0.75,1.5]);
    }
}


if(false)
{
    axialfan(width=40*mm, depth=10.5*mm, mount_dist=32*mm, thread=ThreadM3, orient=Y, align=N);
    %axialfan_cut(width=40*mm, depth=10.5*mm, mount_dist=32*mm, screw_l=25*mm, thread=ThreadM3, orient=Y, align=N);
}
