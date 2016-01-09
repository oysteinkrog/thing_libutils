use <shapes.scad>
include <bearing_data.scad>

module bearing(bearing_type, orient=[0,0,1], align=[0,0,0])
{
    size_align(size=[bearing_type[1],bearing_type[1],bearing_type[2]], align=align ,orient=orient)
    difference()
    {
        // outer
        fncylindera(h=bearing_type[2], d=bearing_type[1], align=[0,0,0]);
        // inner
        fncylindera(h=bearing_type[2]+1, d=bearing_type[0], align=[0,0,0]);
        // clips
        if(len(bearing_type) > 3)
        {
            clip_depth=.5;
            for(j=[-1,1])
            translate([0,0,j*bearing_type[3]/2])
            difference()
            {
                fncylindera(h=1, d=bearing_type[2]+1, align=[0,0,0]);
                fncylindera(h=2, d=bearing_type[4]-clip_depth, align=[0,0,0]);
            }

        }
    }
}

module bearing_mount_holes(bearing_type, ziptie_type=[2*mm, 3*mm], ziptie_bearing_distance=2*mm, orient=[1,0,0], ziptie_dist=undef, show_zips=false)
{
    ziptie_thickness = ziptie_type[0];
    ziptie_width = ziptie_type[1]+0.6*mm;

    ziptie_dist_ = ziptie_dist==undef?bearing_type[3]/2:ziptie_dist;
    ziptie_thickness_cut = bearing_type[1]+ziptie_bearing_distance+ziptie_thickness*3;

    orient(orient)
    {
        // Main bearing cut
        fncylindera(h=bearing_type[2], d=bearing_type[1]*rod_fit_tolerance, orient=[0,0,1]);

        for(i=[-1,1])
        translate([0,0,i*ziptie_dist_])
        hollow_cylinder(
                d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                thickness = ziptie_thickness*3,
                h = ziptie_width,
                taper=true,
                orient=[0,0,1]
                );


        // bearing
        fncylindera(h=bearing_type[2], d=bearing_type[1], orient=[0,0,1]);

        // for linear rod
        fncylindera(d=bearing_type[0]*1.5, h=100, orient=[0,0,1]);

        if(show_zips)
        {
            for(i=[-1,1])
            translate([0,0,i*ziptie_dist_])
            {
                %hollow_cylinder(
                        d=bearing_type[1]+ziptie_bearing_distance+ziptie_thickness,
                        thickness = ziptie_thickness,
                        h = ziptie_width,
                        orient=[0,0,1]
                        );
            }
        }
    }
}

/*bearing_mount_holes(zaxis_bearing, orient=[0,0,1]);*/
