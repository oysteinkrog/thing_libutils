include <system.scad>
include <units.scad>

use <transforms.scad>;
use <shapes.scad>
include <bearing_data.scad>
include <misc.scad>

module bearing(bearing_type, extra_h=0, override_h=U, orient=Z, align=N)
{
    h = fallback(override_h, bearing_type[2]) + extra_h;
    size_align(size=[bearing_type[1],bearing_type[1],h], align=align ,orient=orient)
    difference()
    {
        // outer
        cylindera(h=h, d=bearing_type[1], align=N);
        // inner
        cylindera(h=h+.1, d=bearing_type[0], align=N);
        // clips
        if(len(bearing_type) > 3)
        {
            clip_depth=.5;
            for(z=[-1,1])
            translate([0,0,z*bearing_type[3]/2])
            difference()
            {
                cylindera(h=1*mm, d=bearing_type[2]+1, align=-z*Z);
                cylindera(h=1*mm+.1, d=bearing_type[4]-clip_depth, align=-z*Z);
            }

        }
    }
}

module bearing_mount_holes(bearing_type, extra_h=0, override_h=U, ziptie_type=[2*mm, 3*mm], ziptie_bearing_distance=3*mm, tolerance=1.01, align=N, orient=Z, ziptie_dist=U, with_zips=true)
{
    ziptie_thickness = ziptie_type[0];
    ziptie_width = ziptie_type[1]+0.6*mm;

    ziptie_dist_ = fallback(ziptie_dist, bearing_type[3]/2);

    h = fallback(override_h, bearing_type[2]) + extra_h;
    size_align(size=[bearing_type[1],bearing_type[1],h], align=align ,orient=orient)
    {
        // Main bearing cut
        cylindera(h=bearing_type[2]*tolerance, d=bearing_type[1]*tolerance, orient=Z);

        if(with_zips)
        {
            for(z=[-1,1])
                translate([0,0,z*ziptie_dist_ - z*1/2])
                    hollow_cylinder(
                            d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                            thickness = ziptie_thickness*2,
                            h = ziptie_width,
                            taper=false,
                            orient=Z,
                            align=N
                            );
        }

        // for linear rod
        cylindera(d=bearing_type[0]+2*mm, h=100, orient=Z);

        if($show_vit)
        {
            %bearing(bearing_type=bearing_type);

            for(z=[-1,1])
            translate([0,0,z*ziptie_dist_])
            {
                %hollow_cylinder(
                        d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                        thickness = ziptie_thickness,
                        h = ziptie_width,
                        taper=false,
                        orient=Z,
                        align=-z*Z
                        );
            }
        }
    }
}

if(false)
{
    b=bearing_igus_rj4jp_01_12;
    bearing_mount_holes(b, orient=Z);
    translate([30,0,0])
    bearing(b, orient=Z);
}
