include <units.scad>
use <shapes.scad>

// h, full_h, inner_d, outer_d, walls, bore
pulley_2GT_20T_idler = [8.65*mm, U, 12*mm, 18*mm, 1*mm, 5*mm];
pulley_2GT_20T       = [8.65*mm, 16*mm, 12*mm, 16*mm, 1.15*mm, 5*mm];

function pulley_height(pulley) = pulley[1]==U?pulley[0]:pulley[1];

module pulley(pulley=pulley_2GT_20T, flip=false, align=N, orient = Z)
{
    is_idler = pulley[1] == U;
    pulley_full(
            is_idler=is_idler,
            h=pulley[0],
            full_h=is_idler?U:pulley[1],
            inner_d=pulley[2],
            outer_d=pulley[3],
            walls=pulley[4],
            bore=pulley[5],
            flip=flip,
            align=align,
            orient=orient
            );
}

module pulley_full(h, inner_d, outer_d, bore, walls, is_idler=false, full_h, flip=false, align=N, orient = Z)
{
    size_align(size=[outer_d, outer_d, full_h==U?h:full_h], align=align, orient=orient)
    {
        //for flipping
        mirror([0,0,flip?-1:0])
        //center
        translate([0,0,full_h==U?-h/2:-full_h/2])
        difference()
        {
            union()
            {
                cylindera(d = outer_d, h = walls, align=Z, orient=Z);

                translate(N)
                cylindera(d = inner_d, h = h, align=Z, orient=Z);

                translate([0,0,h-walls])
                cylindera(d = outer_d, h = walls, align=Z, orient=Z);

                translate([0,0,h])
                if(!is_idler)
                {
                    cylindera(d = outer_d, h = full_h-h, align=Z, orient=Z);
                }
            }
            translate([0,0,-.1])
            cylindera(d = bore, h = full_h+.2, align=Z, orient=Z);
        }
    }
}

if(false)
{
    /*pulley(pulley_2GT_20T_idler, align=Z, orient=Z);*/
    pulley(pulley_2GT_20T, align=Z, orient=-Z, flip=false);
    /*pulley(pulley_2GT_20T, align=-Z, orient=Z, flip=false);*/
}
