include <units.scad>
include <system.scad>
include <materials.scad>
include <timing-belts-data.scad>

use <shapes.scad>
include <transforms.scad>

/*test();*/

function belt_t2_thickness(belt) = get(TimingBeltBackThick, belt) * 1.05 * 2 + get(TimingBeltMaxHeight, belt) * 1.05;

module test()
{
    for(preview=[true, false])
    for(belt_i=[0:len(AllTimingBelts)-1])
    {
        belt=AllTimingBelts[belt_i];

        translate((preview?50*mm:0)*Y + belt_i*30*mm*Z)
        stack(axis=X, dist=2*30*mm)
        {

            rotate([90,0,0])
            belt_path(orient=X, len=30*mm, $preview_mode=preview);

            belt_len(belt=belt, belt_width=10, len=30*mm, align=N, orient=X, $preview_mode=preview);
            belt_angle(belt=belt, r=20, belt_width=10, angle=180, align=N, $preview_mode=preview);
        }
    }
}

module belt_path(len=200*mm, belt_width=6*mm, pulley_d=10*mm, belt=TimingBelt_GT2_2, align=N, orient=Z)
{
    material(Mat_Rubber)
    size_align(size=[pulley_d, belt_width, len], align=align, orient=orient)
    {
        for(y=[-1,1])
        translate([0,pulley_d/2,0])
        rotate([180,0,0])
        belt_len(belt=belt, belt_width=belt_width, len=len, align=N, orient=Z);

        translate([0,-pulley_d/2,0])
        belt_len(belt=belt, belt_width=belt_width, len=len, align=N, orient=Z);

        for(i=[-1,1])
        translate([0,0,i*len/2])
        belt_angle(belt=belt, r=pulley_d/2, belt_width=belt_width, angle=180, orient=-X*i);
    }
}

module belt_angle(belt = TimingBelt_GT2_2, r=25, belt_width = 6, angle=90, orient=Z, align=N)
{
    pitch = get(TimingBeltPitch, belt);
    bk = get(TimingBeltBackThick, belt);
    av=360/2/r/3.14159*pitch;

    nn=ceil(angle/av);
    ang=av*nn;

    s=[r+bk,r+bk,belt_width];
    material(Mat_Rubber)
    size_align(size=s, align=align, orient=orient)
    translate([0,-r,0])
    {
        if($preview_mode)
        {
            difference()
            {
                translate([0,-bk,0])
                pie_slice(r=r+bk,start_angle=-90,end_angle=angle-90,h=belt_width, align=[0,1,-1]);

                translate([0,bk,0])
                pie_slice(r=r-bk,start_angle=-90,end_angle=angle-90,h=belt_width+.2, align=[0,1,-1]);

                translate([0,r,0])
                {
                    x = (r-bk)*2/sqrt(2);
                    rotate([0,0,45])
                    cubea(size=[x, x, belt_width+.2], align=N);
                }
            }
        }
        else
        {
            intersection()
            {
                translate([0,-bk,0])
                pie_slice(r=r+bk,start_angle=-90,end_angle=angle-90,h=belt_width, align=[0,1,-1]);

                union ()
                {
                    for(i=[0:nn])
                    {
                        translate ([0,r,-belt_width/2])
                        rotate ([0,0,av*i])
                        translate ([0,-r,0])
                        draw_tooth(belt,0,belt_width);
                    }

                    translate ([0,r,-belt_width/2])
                    rotate([0,0,-90])
                    rotate_extrude(angle = angle)
                    polygon([[r,0],[r+bk,0],[r+bk,belt_width],[r,belt_width]]);
                }
            }
        }
    }
}

//inner module
module belt_len(belt = TimingBelt_GT2_2, len = 10, belt_width = 6, orient=Z, align=N) {

    pitch = get(TimingBeltPitch, belt);
    bk = get(TimingBeltBackThick, belt);
    n = ceil(len/pitch);

    s = [len,belt_width,belt_width];
    material(Mat_Rubber)
    size_align(size=s, align=align, orient=orient, orient_ref=X)
    {
        if($preview_mode)
        {
            cubea(size=[len+1,bk*2,belt_width]);
        }
        else
        {
            intersection()
            {
                translate([-len/2,0,-belt_width/2])
                union()
                {
                    for(i = [0:n])
                    {
                        draw_tooth(belt,i,belt_width);
                    }
                    translate([0,-bk,0])
                    cube([len,bk,belt_width]);
                }
                cubea(size=[len+1,bk*2,belt_width]);
            }
        }
    }
}

module draw_tooth(belt, n, belt_width)
{
    pitch = get(TimingBeltPitch, belt);
    bk = get(TimingBeltBackThick, belt);
    p = get(TimingBeltToothPolygon, belt);

    translate([pitch*n,0,0])
    linear_extrude(height=belt_width)
    polygon(p);
}


