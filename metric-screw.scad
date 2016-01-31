include <shapes.scad>

include <metric-thread-data.scad>
include <metric-hexnut-data.scad>

// naive, assume head height is same as thread size (generally true for cap heads)
function get_screw_head_h(nut) = lookup(ThreadSize, nut);
function get_screw_head_d(nut) = 2 * lookup(ThreadSize, nut);

module screw_cut(nut=MHexNutM3, h=10, tolerance=1.05, head_embed=false, with_nut=true, nut_offset=0, orient=[0,0,1], align=[0,0,0])
{
    threadsize = lookup(ThreadSize, nut);
    head_h = get_screw_head_h(nut);
    nut_h = lookup(MHexNutThickness,nut)*tolerance;
    thread = get(MHexNutThread, nut);

    s = threadsize*tolerance;
    total_h = h;
    size_align(size=[s, s, total_h], orient=-orient, align=align)
    {
        translate([0,0,head_embed?-head_h:0])
        /*translate([0,0,-total_h/2])*/
        {
            translate([0,0,h/2+.01])
            {
                screw_head_cut(nut, orient=[0,0,1], align=[0,0,1]);
            }
            screw_thread_cut(thread=thread, h=h+.1, tolerance=tolerance, orient=[0,0,1], align=[0,0,0]);

            if(with_nut)
            {
                translate([0,0,-h/2+nut_h+nut_offset+(head_embed?head_h:0)])
                screw_nut_cut(nut=nut, tolerance=tolerance, orient=[0,0,1], align=[0,0,-1]);
            }
        }
    }
}

module screw_thread_cut(thread=ThreadM3, h=10, tolerance=1.05, orient=[0,0,1], align=[0,0,0])
{
    threadsize = lookup(ThreadSize, thread[1]);
    cylindera(d=threadsize, h=h, orient=orient, align=align);
}

module screw_head(nut=MHexNutM3, tolerance=1.00, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    threadsize = lookup(ThreadSize, nut);
    head_h = get_screw_head_h(nut);
    head_d = get_screw_head_d(nut);
    cylindera(d=head_d, h = override_h==undef?head_h:override_h, orient=orient, align=align);
}

module screw_head_cut(nut=MHexNutM3, tolerance=1.05, h=1000, orient=[0,0,1], align=[0,0,0])
{
    screw_head(nut=nut, tolerance=tolerance, override_h=1000, orient=orient, align=align);
}

module screw_nut(nut=MHexNutM3, tolerance=1.00, override_h=undef, orient=[0,0,1], align=[0,0,0])
{
    thickness = lookup(MHexNutThickness,nut)*tolerance;
    d = lookup(MHexNutWidthMin, nut)*tolerance;
    cylindera($fn=6, d=d, h=override_h==undef?thickness:override_h, orient=orient, align=align);
}

module screw_nut_cut(nut=MHexNutM3, tolerance=1.05, h=1000, orient=[0,0,1], align=[0,0,0])
{
    thickness = lookup(MHexNutThickness,nut)*tolerance;
    d = lookup(MHexNutWidthMin, nut)*tolerance;
    size_align([d,d,thickness], orient=orient, align=align)
    {
        translate([0,0,thickness/2])
        {
            screw_nut(nut, tolerance, orient=[0,0,1], align=[0,0,-1]);
            translate([0,0,-thickness+.01])
            {
                cylindera(d=d*1.1, h=h, orient=[0,0,1], align=[0,0,-1]);
            }
        }
    }
}

function get(key, dict) =
    let(x= search(MHexNutThread, MHexNutM3))
    dict[x[0]];


if(false)
{
    nut1 = MHexNutM3;
    nut2 = MHexNutM5;

    box_h = 10;
    difference()
    {
        cubea([50,10,box_h], align=[1,1,-1]);

    #union()
        {
            translate([5,0,0])
                screw_cut(nut=nut1, h=box_h, head_embed=false, orient=[0,0,-1], align=[0,0,-1]);

            translate([15,0,0])
                screw_cut(nut=nut1, h=box_h*mm, nut_offset=0*mm, head_embed=true, orient=[0,0,-1], align=[0,0,-1]);

            translate([25,0,0])
                screw_cut(nut=nut1, h=box_h*mm, nut_offset=3*mm, head_embed=false, orient=[0,0,-1], align=[0,0,-1]);
        }

    }

}
