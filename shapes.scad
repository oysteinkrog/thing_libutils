include <system.scad>
include <units.scad>
use <misc.scad>
use <transforms.scad>

module cubea(size=[10,10,10], align=[0,0,0], extrasize=[0,0,0], extrasize_align=[0,0,0], orient=[0,0,1], roll=0, extra_roll, extra_roll_orient)
{
    size_align(size=size,extra_size=extrasize, align=align, extra_align=extrasize_align, orient=orient, orient_ref=[0,0,1], roll=roll, , extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
    {
        cube(size+extrasize, center=true);
    }
}

module rcubea(size=[10,10,10], rounding_radius=1, align=[0,0,0], extrasize=[0,0,0], extrasize_align=[0,0,0], orient=[0,0,1], roll=0, extra_roll, extra_roll_orient)
{
    size_align(size=size,extra_size=extrasize, align=align, extra_align=extrasize_align, orient=orient, orient_ref=[0,0,1], roll=roll, extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
    {
        rcube(size=size+extrasize, rounding_radius=rounding_radius);
    }
}

/*cubea(size=[10,20,30], align=[0,-1,0], orient=[0,0,1], roll=10, extra_roll=-30, extra_roll_orient=[1,0,0]);*/

module rcube(size=[20,20,20], rounding_radius=1)
{
    if($preview_mode || rounding_radius == 0)
    {
        cubea(size);
    }
    else
    {
        hull()
        for(x=[-(size[0]/2-rounding_radius),(size[0]/2-rounding_radius)])
        for(y=[-(size[1]/2-rounding_radius),(size[1]/2-rounding_radius)])
        for(z=[-(size[2]/2-rounding_radius),(size[2]/2-rounding_radius)])
        translate([x,y,z])
        sphere(r=rounding_radius);
    }
}


module cylindera(
        h=10,
        r=undef,
        r1=undef,
        r2=undef,
        d=undef,
        d1=undef,
        d2=undef,
        align=[0,0,0],
        orient=[0,0,1],
        extra_h=0,
        extra_r=undef,
        extra_d=undef,
        extra_align=[0,0,0],
        round_radius=0,
        debug=false
        )
{
    pi=3.1415926536;

    d1_ = v_fallback(d1, [r*2, r1*2]);
    d2_ = v_fallback(d2, [r*2, r2*2]);

    r1_ = v_fallback(r1, [d1_/2, d/2, r]);
    r2_ = v_fallback(r2, [d2_/2, d/2, r]);

    r_max = v_fallback(r, [max(r1_,r2_)]);

    extra_r_ = v_fallback(extra_r, [0]);

    if(debug)
    {
        echo(useDia, h, r_, r1_, r2_, extra_r_, align);
    }

    size_align(size=[r_max*2,r_max*2,h], extra_size=[extra_r_*2, extra_r_*2, extra_h], orient=orient, orient_ref=[0,0,1], align=align, extra_align=extra_align)
    {
        if(round_radius>0)
        {
            rcylinder(h=h+extra_h, r1=r1_+extra_r_, r2=r2_+extra_r_, round_radius=round_radius);
        }
        else
        {
            cylinder(h=h+extra_h, r1=r1_+extra_r_, r2=r2_+extra_r_, center=true);
        }
    }
}

/*translate([10,0,0])*/
/*rotate_extrude()*/
        /*translate([10-2,2,0])*/
/*$fa = 5.6;*/
/*$fs = 0.3;*/
/*circle(r = 100);*/
/*torus(10, 2, align=[0,0,0], orient=[0,0,1]);*/

module torus(radius, radial_width, align=[0,0,0], orient=[0,0,1])
{
    size_align(size=[radius*2+radial_width*2, radius*2+radial_width*2, radial_width*2], align=align, orient=orient)
    rotate_extrude()
    translate([radius, 0, 0])
    circle(radial_width);
}

module rcylinder(d, d1, d2, r, r1, r2, h=10, round_radius=2, align=[0,0,0], orient=[0,0,1])
{
    if($preview_mode || round_radius == 0 || true)
    {
        cylindera(d=d, d1=d1, d2=d2, r=r, r1=r1, r2=r2, h=h, align=align, orient=orient);
    }
    else
    {
        d1_ = v_fallback(d1, [r*2, r1*2]);
        d2_ = v_fallback(d2, [r*2, r2*2]);

        r1_ = v_fallback(r1, [d/2, d1_/2]);
        r2_ = v_fallback(r2, [d/2, d2_/2]);

        r_ = [r1_,r2_];

        size_align(align=align, orient=orient)
            hull()
            {
                for(z=[-1,1])
                    translate([0, 0, z*(-h/2)])
                    {
                        r__=z!=-1?r_[0]:r_[1];
                        torus(radius=r__-round_radius/2, radial_width=round_radius/2, align=[0,0,z]);
                    }
            }
    }
}

// positive angles go from start to end counterclockwise
// negative angles are allowed
module pie_slice_shape(r, start_angle, end_angle) {
    R = r * sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    intersection() {
        circle(r);
        polygon([
                [0,0],
                [R * cos(a0), R * sin(a0)],
                [R * cos(a1), R * sin(a1)],
                [R * cos(a2), R * sin(a2)],
                [R * cos(a3), R * sin(a3)],
                [R * cos(a4), R * sin(a4)],
                [0,0]
        ]);
    }
}

// positive angles go from start to end counterclockwise
// negative angles are allowed
module pie_slice(r, start_angle, end_angle, h, orient=[0,0,1], align=[0,0,0])
{
    size_align(size=[r*2, r*2, h], orient=orient, orient_ref=[0,0,1], align=align)
    linear_extrude(h)
    {
        pie_slice_shape(r, start_angle, end_angle);
    }
}

module hollow_cylinder(d=10, thickness=1, h=10, taper=false, taper_h=undef, orient=[0,0,1], align=[0,0,0])
{
    outer_d = d+thickness/2;
    inner_d = d-thickness/2;
    taper_h = taper_h == undef ? min(h/4, (outer_d-inner_d)/2) : max(taper_h,h/2);
    taper_ = taper && taper_h > 0;
    size_align(size=[outer_d, outer_d, h], orient=orient, align=align);
    difference()
    {
        union()
        {
            cylindera(h=h-(taper_?taper_h*2:0), d=outer_d, orient=[0,0,1], align=[0,0,0]);
            if(taper_)
            {
                for(z=[-1,1])
                translate([0,0,z*(h/2-taper_h)])
                mirror([0,0,z==-1?1:0])
                cylindera(d1=outer_d, d2=outer_d-inner_d/4, h=taper_h, align=[0,0,1]);
            }
        }
        if(taper_)
        {
            for(z=[-1,1])
            translate([0,0,z*(h/2-taper_h)])
            mirror([0,0,z==-1?1:0])
            cylindera(d1=inner_d, d2=outer_d, h=taper_h+.1, align=[0,0,1]);

            // override fn for inner cylinder cut, to ensure same fragments as taper
            // this ensures cleaner mesh
            fn = fn_from_d(d=outer_d);
            cylindera(h=h+.2+taper_h, d=inner_d, orient=[0,0,1], align=[0,0,0], $fn=fn);
        }
        else
        {
            cylindera(h=h+.2, d=inner_d, orient=[0,0,1], align=[0,0,0]);
        }
    }
}


/**
 * Standard right-angled triangle
 *
 * @param number o_len Lenght of the opposite side
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 * @todo a better way ?
 */
module triangle(o_len, a_len, depth, align=[0,0,0], orient=[0,0,1])
{
    size_align(size=[a_len, depth, o_len], align=align, orient=orient)
    rotate([90,0,0])
    translate([-a_len/2, -o_len/2, -depth/2])
    linear_extrude(height=depth)
    {
        polygon(points=[[0,0],[a_len,0],[0,o_len]], paths=[[0,1,2]]);
    }
}

/**
 * Rounded Standard right-angled triangle
 *
 * @param number o_len Lenght of the opposite side
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 * @todo a better way ?
 */
module rtriangle(o_len, a_len, depth, rounding_radius=2, align=[0,0,0], orient=[0,0,1])
{
    size = [a_len-rounding_radius, depth-rounding_radius, o_len-rounding_radius];
    r_x = rounding_radius;
    r_y = rounding_radius;
    r_z = -rounding_radius;

    hyp = pythag_hyp(o_len,a_len);
    a_z = atan(a_len/o_len);

    translate([0,0,size[2]+2])
    color([1,0,0])
    rotate([90,90,0])
    pie_slice(r=2, start_angle=0, end_angle=a_z, h=depth);

    /*translate([size[0]+4,0,0])*/
    /*color([1,0,0])*/
    /*rotate([90,90,0])*/
    /*pie_slice(r=2, start_angle=90, end_angle=90+a_z, h=depth);*/

    size_align(size=size, align=align, orient=orient)
    /*hull()*/
    for(x=[-(size[0]/2)+rounding_radius,(size[0]/2)-r_x])
    for(y=[-(size[1]/2)+rounding_radius,(size[1]/2)-r_y])
    for(z=[-(size[2]/2)+rounding_radius,(size[2]/2)-r_z])
    translate([x,y,z])
    if(x<=1 || z<=1)
    sphere(r=rounding_radius);
}

module teardrop(r, d, h=10, truncate=1, align=[0,0,0], orient=[0,1,0], roll=0)
{
    r_= v_fallback(r, [d/2]);

    sx1 = r_ * sin(-45);
    sx2 = r_ * -sin(-45);
    sy = r_ * -cos(-45);
    ex = 0;
    ey = (sin(-135) + cos(-135)) * r_;

    dx= ex-sx1;
    dy = ey-sy;

    eys = lerp(-r_,ey,1-truncate);

    dys = eys-sy;
    ex1 = sy+dys*dx/dy;
    ex2 = -ex1;

    size_align(size=[d,d,h], align=align, orient=orient, orient_ref=[0,0,1], roll=roll)
    union()
    {
        linear_extrude(height = h, center = true, convexity = r_, twist = 0)
        circle(r = r_, center = true);

        linear_extrude(height = h, center = true, convexity = r_, twist = 0)
        polygon(points = [
                [sy, sx1],
                [sy, sx2],
                [eys, ex2],
                [eys, ex1]],
                paths = [[0, 1, 2, 3]]);
    }
}

// test teardrop
if(false)
{
    r=5*mm;
    for(axis=concat(AXES,-AXES))
    translate(axis*r*2)
    {
        c= v_abs(axis*.3 + v_clamp(v_sign(axis),0,1)*.7);
        color(c)
        teardrop(r=r, h=20, orient=axis, align=axis);
    }
}

// test cubea
if(false)
{
    w=5*mm;
    h=2*mm;
    for(axis=concat(AXES,-AXES))
    /*translate(axis)*/
    {
        c= v_abs(axis*.3 + v_clamp(v_sign(axis),0,1)*.7);
        color(c)
        cubea([w,w,h], orient=axis, align=axis*3);
    }
}
/**
/*debug();*/

module debug()
{
    $fs = 0.1;
    $fa = 1;

    /*triangle_a(45, 5, 5);*/
    /*triangle(15, 10, 5, align=[1,1,1], orient=[0,0,-1]);*/
    /*triangle(15, 10, 5, align=[1,1,1], orient=[0,0,1]);*/

    triangle(10, 30, 5, align=[1,1,1], orient=[0,0,1]);
    translate([0,-10,0])
    rtriangle(10, 30, 5, align=[1,1,1], orient=[0,0,1]);
}

/**
 * Standard right-angled triangle (tangent version)
 *
 * @param number angle of adjacent to hypotenuse (ie tangent)
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 */
module triangle_a(tan_angle, a_len, depth)
{
    linear_extrude(height=depth)
    {
        polygon(points=[[0,0],[a_len,0],[0,tan(tan_angle) * a_len]], paths=[[0,1,2]]);
    }
}

// Tests:
module test_triangles()
{
    // Generate a bunch of triangles by sizes
    for (i = [1:10])
    {
        translate([i*7, -30, i*7])
        {
            triangle(i*5, sqrt(i*5+pow(i,2)), 5);
        }
    }

    // Generate a bunch of triangles by angle
    for (i = [1:85/5])
    {
        translate([i*7, 22, i*7])
        {
            triangle_a(i*5, 10, 5);
        }
    }
}


if(false)
{
    stack(axis=XAXIS, dist=15)
    {
        hollow_cylinder(thickness=5, h=10, taper=false, orient=[0,0,1], align=[0,0,1]);
        hollow_cylinder(thickness=5, h=10, taper=true, orient=[0,0,1], align=[0,0,1]);
    }

    /*cylindera(d=10, h=10, orient=[0,0,1], align=[0,0,1]);*/
    /*translate([10,0,0])*/
    /*{*/
    /*hollow_cylinder(d=10, thickness=4, h=10, taper=true, taper_h=.5, orient=[0,0,1], align=[0,0,1]);*/
    /*cylindera(d=8, h=10, orient=[0,0,1], align=[0,0,1]);*/
    /*}*/

    /*%pie_slice(r=10, start_angle=-30, end_angle=270, h=10);*/

    /*cubea([10,10,10],[1,0,0]);*/
    /*%cubea([10,10,10],[1,0,0],[5,5,5],[1,1,1]);*/

    /*%cubea([10,10,10],[-1,0,1]);*/
    /*%cubea([10,10,10],[-1,0,1],[1,1,1],[-1,0,1]);*/
    /*%cylindera(h=10, r=10/2, align=[-1,1,1], extra_r=5/2, extra_h=2, extra_align=[-1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[-1,1,1], extra_d=5, extra_h=2, extra_align=[-1,1,1], $fn=100);*/
    /*%cylindera(h=10, d=10, align=[1,1,1], extra_d=15, extra_h=2, extra_align=[1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[1,-1,1], extra_d=5, extra_h=2, extra_align=[-1,-1,1], $fn=100);*/
    /*%cylindera(h=10, d=10, align=[1,1,1], extra_d=5, extra_h=2, extra_align=[1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[1,0,0], extra_d=10);*/

    /*hull_pairwise()*/
    /*sphere(30/2);*/

    /*translate([30,0,0])*/
    /*rcubea(s=[35,35,35], rounding_radius=10);*/
    /*rcubea(s=[35,35,35], align=[0,-1,0]);*/

    /*translate([60,0,0])*/
    /*sphere(30/2);*/


    cylindera(h=20, r=5*mm, align=[0,1,0], orient=[0,0,1], $fn=100);

/*size_align(size=[5,5,20], orient=[0,1,0], orient_ref=[0,0,1])*/
/*size_align(size=[5,5,20], orient=[0,1,0], orient_ref=[0,1,0], align=[0,1,0])*/
/*size_align(size=[5,20,5], orient=[0,0,1], orient_ref=[0,1,0], align=[0,0,0])*/
/*rotate([90,0,0])*/
/*cylinder(d=5, h=20, center=true);*/

/*cylindera(d=10, h=10, orient=[0,1,0], align=[0,0,1]);*/
}


if(false)
{
    r=5*mm;
    for(axis=concat(AXES,-AXES))
    translate(axis*r*2)
    {
        c= v_abs(axis*.3 + v_clamp(v_sign(axis),0,1)*.7);
        color(c)
        /*cylindera(h=20, r=r, align=axis, orient=axis, extra_h=r, extra_align=-axis, $fn=100);*/
        cylindera(h=20, r1=r, r2=r/2, align=axis, orient=axis, extra_h=r, extra_align=-axis, $fn=16, round_radius=2);
    }
}

if(false)
{
    stack(dist=50, axis=[0,1,0])
    {
        stack(dist=10, axis=[0,0,-1])
        {
            /*cylindera(orient=[0,0,-1], align=[0,0,-1]);*/
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,0,1], align=[0,0,-1]);
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,0,-1], align=[0,0,1]);
            /*pie_slice(r=30, h=5, start_angle=-90, end_angle=180, align=[0,0,-1]);*/
            /*pie_slice(r=30, h=5, start_angle=90, end_angle=270, align=[0,0,-1]);*/
            /*pie_slice(r=30, h=5, start_angle=0, end_angle=270, align=[0,0,-1]);*/
        }

        stack(dist=10, axis=[0,1,0])
        {
            /*cylindera(orient=[0,1,0], align=[0,1,0]);*/
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,-1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=[0,1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=-90, end_angle=180, orient=[0,1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=90, end_angle=270, orient=[0,1,0], align=[0,1,0]);
            pie_slice(r=30, h=5, start_angle=0, end_angle=270, orient=[0,1,0], align=[0,1,0]);
        }
    }
}
