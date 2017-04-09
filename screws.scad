include <system.scad>
include <thread-data.scad>
include <nut-data.scad>
include <materials.scad>

use <shapes.scad>
use <transforms.scad>
use <misc.scad>

// naive, assume head height is same as thread size (generally true for cap heads)
function get_screw_head_h(head, thread) = get(ThreadSize, thread);
function get_screw_head_d(head, thread) = 2 * get(ThreadSize, thread);

module screw(nut, thread, head="socket", h=10, tolerance=1.05, head_embed=false, with_nut=true, with_head=true, nut_offset=0, orient=Z, align=N)
{
    nut_thread = get(NutThread, nut);
    thread_ = fallback(thread, nut_thread);
    assert(thread_ != U, "screw: No nut or thread given");
    assert(head != U, "screw: head == U");
    /*assert(nut!=U && thread!=U && nut_thread != thread_, "screw: Mismatched nut and thread");*/

    head_h = get_screw_head_h(head=head, thread=thread_);
    nut_h = get(NutThickness,nut)*tolerance;
    threadsize = get(ThreadSize, thread_);

    s = threadsize*tolerance;
    total_h = h;
    size_align(size=[s, s, total_h], orient=-orient, orient_ref=Z, align=align)
    {
        translate([0,0,head_embed?-head_h:0])
        {
            if(with_head)
            {
                translate([0,0,h/2+.01])
                screw_head(head=head, thread=thread_, orient=Z, align=Z);
            }

            screw_thread(thread=thread_, h=h+.1, tolerance=tolerance, orient=Z, align=N);

            if(with_nut && nut != U)
            {
                translate([0,0,-h/2+nut_h+nut_offset+(head_embed?head_h:0)])
                screw_nut(nut=nut, tolerance=tolerance, orient=Z, align=-Z);
            }
        }

        if($show_vit)
        {
            if(with_nut && nut != U)
            {
                translate([0,0,-h/2+nut_h+nut_offset+(head_embed?head_h:0)])
                %screw_nut(nut=nut, align=-Z);
            }
        }
    }
}

module screw_cut(nut, thread, head="socket", h=10, tolerance=1.05, head_embed=false, with_nut=true, nut_cut_h=1000, with_head=true, head_cut_h=1000, nut_offset=0, cut_access=true, orient=Z, align=N)
{
    nut_thread = get(NutThread, nut);
    thread_ = fallback(thread, nut_thread);
    assert(thread_ != U, "screw_cut: No nut or thread given");
    /*assert(nut!=U && thread!=U && nut_thread != thread_, "screw_cut: Mismatched nut and thread");*/

    nut_h = get(NutThickness,nut)*tolerance;
    assert(head != U, "screw_cut: head == U");

    head_h = get_screw_head_h(head=head, thread=thread_);
    assert(head_h != U, "screw_cut: head_h is U!");

    threadsize = get(ThreadSize, thread_);
    assert(threadsize != U, "screw_cut: threadsize is U!");

    s = threadsize*tolerance;
    total_h = h;
    assert(s != U, "screw_cut: s is U!");
    size_align(size=[s, s, total_h], orient=-orient, orient_ref=Z, align=align)
    {
        translate([0,0,head_embed?-head_h:0])
        {
            if(with_head)
            {
                translate([0,0,h/2+.01])
                screw_head_cut(head=head, thread=thread_, tolerance=tolerance, override_h=head_cut_h, align=Z);
            }

            screw_thread_cut(thread=thread_, h=h+.1, tolerance=tolerance, orient=Z, align=N);

            if(with_nut && nut != U)
            {
                translate([0,0,-h/2+nut_h+nut_offset+(head_embed?head_h:0)])
                screw_nut_cut(nut=nut, tolerance=tolerance, h=nut_cut_h, align=-Z);
            }

            if($show_vit)
            {
                %screw(nut=nut, thread=thread, head=head, h=h, tolerance=tolerance, with_nut=with_nut, with_head=with_head, nut_offset=nut_offset, orient=-Z, align=N);
            }
        }
    }
}

module screw_thread(thread, h=10, tolerance=1.00, orient=Z, align=N)
{
    assert(thread!=U, "screw_thread: thread is undef");
    // TODO render thread
    threadsize = get(ThreadSize, thread);

    material(Mat_Steel)
    cylindera(d=threadsize, h=h, orient=orient, align=align);
}

module screw_thread_cut(thread, h=10, tolerance=1.05, orient=Z, align=N)
{
    assert(thread!=U, "screw_thread_cut: thread is undef");
    threadsize = get(ThreadSize, thread);
    cylindera(d=threadsize*tolerance, h=h, orient=orient, align=align);
}

module screw_head(head="socket", thread, tolerance=1.00, override_h=U, orient=Z, align=N)
{
    assert(head != U, "screw_head: head == U");
    assert(thread!=U, "screw_head: thread == undef");

    threadsize = get(ThreadSize, thread);
    head_h = get_screw_head_h(head=head, thread=thread);
    head_d = get_screw_head_d(head=head, thread=thread);
    material(Mat_Steel)
    size_align(size=[head_d, head_d, head_h], orient=orient, align=align)
    {
        if(head=="socket")
        {
            difference()
            {
                cylindera(d=head_d, h = fallback(override_h,head_h));
                translate([0,0,head_h/2])
                cylindera(d=threadsize, h = head_d/2);
            }
        }
        else
        {
            c = head_d;
            f = head_h*1.25;
            r = ( pow(c,2)/4 + pow(f,2) )/(2*f); 

            d = r - f; // displacement to move sphere

            difference() {
                /*translate([0, 0, d])*/
                #spherea(r = r, align=-Z);

                translate([0, 0, -r])
                cubea(r*2);

                translate([0, 0, f/3])
                cylinder(r = hexRadius(threadsize), h = f, $fn = 6);

            } // end difference

        }
    }
}

module screw_head_cut(head="socket", thread, tolerance=1.05, override_h=U, orient=Z, align=N)
{
    assert(head != U, "screw_head: head == U");
    assert(thread!=U, "screw_head_cut: thread is undef");

    threadsize = get(ThreadSize, thread);
    head_h = get_screw_head_h(head=head, thread=thread);
    head_d = get_screw_head_d(head=head, thread=thread)*tolerance;
    size_align(size=[head_d, head_d, head_h], orient=orient, align=align)
    translate([0,0,-head_h/2])
    cylindera(d=head_d, h=fallback(override_h, head_h), align=Z);
}

module screw_nut(nut, tolerance=1.00, override_h=U, orient=Z, align=N)
{
    assert(nut!=U, "screw_nut: nut is undef");

    nut_thick = get(NutThickness,nut)*tolerance;
    nut_facets = get(NutFacets, nut);
    nut_dia = nut_dia(nut);
    material(Mat_Steel)
    cylindera($fn=nut_facets, d=nut_dia, h=fallback(override_h, nut_thick), orient=orient, align=align);
}

module screw_nut_cut(nut, tolerance=1.05, h=1000, orient=Z, align=N)
{
    assert(nut!=U, "screw_nut_cut: nut is undef");

    nut_thick = get(NutThickness,nut)*tolerance;
    nut_dia = nut_dia(nut);
    size_align(size=[nut_dia, nut_dia, nut_thick], orient=orient, align=align)
    {
        translate([0,0,nut_thick/2])
        {
            screw_nut(nut, tolerance, orient=Z, align=-Z);
            translate([0,0,-nut_thick+.01])
            {
                cylindera(d=nut_dia+2*mm, h=h, orient=Z, align=-Z);
            }
        }
    }
}

// distance from center to flat on a polygon (taking in the diagonal distance)
function apothem(radius, facets) = radius/cos(180/facets);

function nut_radius(nut) = apothem(get(NutWidthMax, nut)/2, get(NutFacets, nut));
function nut_dia(nut) = 2*nut_radius(nut);
function hex_radius(hexSize) = hexSize/2/sin(60);

module nut_trap_cut(nut, thread, head, trap_offset=10, screw_l=10*mm, screw_offset=0*mm, cut_screw=false, trap_h=10, trap_axis=-Y, orient=Z, align=N)
{
    nut_thread = get(NutThread, nut);
    thread_ = fallback(thread, nut_thread);
    assert(thread_ != U, "nut_trap_cut: No nut or thread given");
    /*assert(nut!=U && thread!=U && nut_thread != thread_, "nut_trap_cut: Mismatched nut and thread");*/

    threadsize = get(ThreadSize, thread_);
    head_h = get_screw_head_h(head=head, thread=thread);
    nut_h = get(NutThickness, nut) +.5*mm;

    nut_width_min = get(NutWidthMin, nut);
    nut_facets = get(NutFacets, nut);
    nut_dia = nut_dia(nut);
    total_h = nut_h;
    size_align(size=[nut_dia, nut_dia, total_h], orient=orient, orient_ref=Z, align=align)
    {
        if(cut_screw)
        {
            translate(-nut_h/2*Z)
            translate(screw_offset*Z)
            screw_cut($show_vit=false, nut=nut, thread=thread_, with_nut=false, tolerance=1.1, h=screw_l, orient=-Z, align=Z);
        }
        else
        {
            translate([0,0,nut_h/2+screw_offset])
            screw_thread_cut($show_vit=false, thread=thread_, tolerance=1.1, h=screw_l, orient=-Z, align=Z);
        }

        hull()
        {
            orient(axis=Z, axis_ref=orient)
            translate(-.15*mm*trap_axis)
            stack(dist=trap_h, axis=trap_axis)
            {
                orient(axis=orient, axis_ref=Z)
                {
                    rotate([0,0,30])
                    cylindera($fn=nut_facets, d=nut_dia, h=nut_h, align=N);
                }

                orient(axis=orient, axis_ref=Z)
                cubea(size=[nut_width_min,nut_width_min,nut_h], align=N);
            }
        }

        if($show_vit)
        {
            translate(-nut_h/2*Z)
            translate(screw_offset*Z)
            %screw(nut=nut, thread=thread_, with_nut=false, tolerance=1, h=screw_l, orient=-Z, align=Z);

            rotate([0,0,30])
            %screw_nut(nut=nut, thread=thread, tolerance=1, orient=-Z, align=N);
        }

    }
}

if(false)
{
    all_axes()
    translate($axis*5*mm)
    color($color)
    screw(nut=NutHexM3, h=10*mm, orient=-$axis, align=$axis);
}

// all nuts
if(false)
{
    for(nuti=[0:1:len(AllNut)-1])
    {
        nut = AllNut[nuti];
        v_threadsize = v_get(AllNut,ThreadSize);
        v_nutwidthmin = v_get(AllNut,NutWidthMin);
        dist = v_cumsum(v_nutwidthmin, 0, nuti)[nuti]*1.2;
        translate(X*dist)
        rotate([0,0,30])
        screw(nut=nut, h=get(NutWidthMax, nut)*5, head_embed=false, orient=-Z, align=Z);
    }
}

if(false)
{
    box_w = 150*mm;
    box_d = 10*mm;
    box_h = 10*mm;
    o = 10*mm;

    $show_vit = true;
    /*$fs= 0.2;*/
    /*$fa = 4;*/

    nut1 = NutHexM3;
    nut2 = NutHexM5;
    nut3 = NutKnurlM3_3_42;
    nut4 = NutKnurlM3_5_42;

    /*all_axes()*/
    /*for($axis=[X])*/
    /*color($color)*/
    /*translate($axis*15)*/
    /*echo($axis)*/

    /*orient(axis=$axis, axis_ref=-X)*/
    for(y=[-1,1])
    translate(-y*Y*20*mm)
    difference()
    {
        cubea([box_w,box_d,box_h], align=X+Z);
        test_cuts(orient=y*Z);
        /*%test_cuts(orient=y, axis_ref=-Z);*/
    }

}

module test_cuts(orient)
{
    union()
    {
        /*offset = 0;*/
        offset = -5;
        /*translate([0,offset,0])*/
        /*translate([5,0,-5])*/
        translate([5,0,0])
        stack(dist=10,axis=X)
        {
            screw_cut(nut=nut1, head="button", h=box_h, head_embed=false, orient=orient, align=Z);
            screw_cut(thread=ThreadM5, h=box_h, head_embed=false, orient=orient, align=Z);
            screw_cut(nut=nut1, h=box_h, head_embed=false, orient=orient, align=Z);

            screw_cut(nut=nut1, h=box_h, nut_offset=0*mm, head_embed=true, orient=orient, align=Z);
            screw_cut(nut=nut2, h=box_h, nut_offset=3*mm, head_embed=false, orient=orient, align=Z);
            screw_cut(nut=nut3, h=box_h, head_embed=false, orient=orient, align=Z);
            screw_cut(nut=nut4, h=box_h, head_embed=false, orient=orient, align=Z);

            translate([0,0,-5*mm])
            screw_cut(nut=nut3, h=box_h, head_embed=false, orient=orient, align=Z);

            translate([0,0,box_h/2])
            nut_trap_cut(nut=nut1, h=5, head_embed=false, trap_h=10, trap_axis=-Y, orient=orient, align=N);

            translate([0,0,box_h/2])
            nut_trap_cut(nut=nut1, h=5, head_embed=false, trap_h=10, trap_axis=Y, orient=orient, align=N);

            translate([0,0,box_h/2])
            nut_trap_cut(nut=nut1, h=box_d, head_embed=false, trap_h=10, screw_offset=2*mm, trap_axis=Z, orient=orient, align=N);

            translate([0,0,box_h/2])
            nut_trap_cut(nut=nut1, h=box_d, head_embed=false, trap_h=10, screw_offset=2*mm, trap_axis=-Z, orient=orient, align=N);
        }
    }
}

