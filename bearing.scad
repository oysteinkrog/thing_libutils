use <shapes.scad>
include <bearing_data.scad>
include <units.scad>

module bearing(bearing_type, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    h = override_h==undef ? bearing_type[2] : override_h;
    size_align(size=[bearing_type[1],bearing_type[1],h], align=align ,orient=orient)
    difference()
    {
        // outer
        fncylindera(h=h, d=bearing_type[1], align=[0,0,0]);
        // inner
        fncylindera(h=h+.1, d=bearing_type[0], align=[0,0,0]);
        // clips
        if(len(bearing_type) > 3)
        {
            clip_depth=.5;
            for(z=[-1,1])
            translate([0,0,z*bearing_type[3]/2])
            difference()
            {
                fncylindera(h=1*mm, d=bearing_type[2]+1, align=[0,0,-z]);
                fncylindera(h=1*mm+.1, d=bearing_type[4]-clip_depth, align=[0,0,-z]);
            }

        }
    }
}

module bearing_mount_holes(bearing_type, ziptie_type=[2*mm, 3*mm], ziptie_bearing_distance=3*mm, tolerance=1.01, orient=[1,0,0], ziptie_dist=undef, show_zips=false)
{
    ziptie_thickness = ziptie_type[0];
    ziptie_width = ziptie_type[1]+0.6*mm;

    ziptie_dist_ = (ziptie_dist==undef?bearing_type[3]/2:ziptie_dist);

    orient(orient)
    {
        // Main bearing cut
        fncylindera(h=bearing_type[2], d=bearing_type[1]*tolerance, orient=[0,0,1]);

        for(z=[-1,1])
        translate([0,0,z*ziptie_dist_ - z*1/2])
        hollow_cylinder(
                d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                thickness = ziptie_thickness*2,
                h = ziptie_width,
                taper=false,
                orient=[0,0,1],
                align=[0,0,0]
                );


        // bearing
        fncylindera(h=bearing_type[2], d=bearing_type[1], orient=[0,0,1]);

        // for linear rod
        fncylindera(d=bearing_type[0]*1.5, h=100, orient=[0,0,1]);

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
