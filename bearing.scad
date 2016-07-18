use <transforms.scad>;
use <shapes.scad>
include <bearing_data.scad>
include <units.scad>
include <misc.scad>

module bearing(bearing_type, extra_h=0, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    h = fallback(override_h, bearing_type[2]) + extra_h;
    size_align(size=[bearing_type[1],bearing_type[1],h], align=align ,orient=orient)
    difference()
    {
        // outer
        cylindera(h=h, d=bearing_type[1], align=[0,0,0]);
        // inner
        cylindera(h=h+.1, d=bearing_type[0], align=[0,0,0]);
        // clips
        if(len(bearing_type) > 3)
        {
            clip_depth=.5;
            for(z=[-1,1])
            translate([0,0,z*bearing_type[3]/2])
            difference()
            {
                cylindera(h=1*mm, d=bearing_type[2]+1, align=[0,0,-z]);
                cylindera(h=1*mm+.1, d=bearing_type[4]-clip_depth, align=[0,0,-z]);
            }

        }
    }
}

module bearing_mount_holes(bearing_type, ziptie_type=[2*mm, 3*mm], ziptie_bearing_distance=3*mm, tolerance=1.01, orient=[1,0,0], ziptie_dist=undef, with_zips=true, show_zips=false)
{
    ziptie_thickness = ziptie_type[0];
    ziptie_width = ziptie_type[1]+0.6*mm;

    ziptie_dist_ = fallback(ziptie_dist, bearing_type[3]/2);

    orient(orient)
    {
        // Main bearing cut
        cylindera(h=bearing_type[2]*tolerance, d=bearing_type[1]*tolerance, orient=[0,0,1]);

        if(with_zips)
        {
            for(z=[-1,1])
                translate([0,0,z*ziptie_dist_ - z*1/2])
                    hollow_cylinder(
                            d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                            thickness = ziptie_thickness*2,
                            h = ziptie_width,
                            taper=true,
                            orient=[0,0,1],
                            align=[0,0,0]
                            );
        }

        // for linear rod
        cylindera(d=bearing_type[0]+1*mm, h=100, orient=[0,0,1]);

        if(show_zips)
        {
            for(z=[-1,1])
            translate([0,0,z*ziptie_dist_])
            {
                %hollow_cylinder(
                        d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                        thickness = ziptie_thickness,
                        h = ziptie_width,
                        orient=[0,0,1],
                        align=[0,0,-z]
                        );
            }
        }
    }
}

if(false)
{
    b=bearing_igus_rj4jp_01_12;
    bearing_mount_holes(b, orient=[0,0,1]);
    translate([30,0,0])
    bearing(b, orient=[0,0,1]);
}
