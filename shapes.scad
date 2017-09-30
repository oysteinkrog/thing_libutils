/*use <../scad-utils/transformations.scad>*/
include <system.scad>
include <units.scad>
use <misc.scad>
use <transforms.scad>

module cubea(size=[10,10,10], align=N, extra_size=N, extra_align=N, orient=Z, orient_ref=Z, roll=0, extra_roll, extra_roll_orient)
{
    size_align(size=size, extra_size=extra_size, align=align, extra_align=extra_align, orient=orient, orient_ref=orient_ref, roll=roll, extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
    cube(size+extra_size, center=true);
}

module rcubea(size=[10,10,10], round_r=1, align=N, extra_size=N, extra_align=N, orient=Z, orient_ref=Z, roll=0, extra_roll, extra_roll_orient)
{
    size_align(size=size, extra_size=extra_size, align=align, extra_align=extra_align, orient=orient, orient_ref=orient_ref, roll=roll, extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
    rcube(size=size+extra_size, round_r=round_r);
}

module rcube(size=[20,20,20], round_r=1)
{
    if($preview_mode || round_r == 0)
    {
        cubea(size);
    }
    else
    {
        hull()
        for(x=[-(size[0]/2-round_r),(size[0]/2-round_r)])
        for(y=[-(size[1]/2-round_r),(size[1]/2-round_r)])
        for(z=[-(size[2]/2-round_r),(size[2]/2-round_r)])
        translate([x,y,z])
        {
            sphere(r=round_r);
        }
    }
}

module spherea(r, d, align=N, extra_r, extra_d, extra_align, orient=Z, orient_ref=Z, roll=0, extra_roll, extra_roll_orient)
{
    d_ = v_fallback(d, [r*2]);
    assert(d_ != U);

    extra_d_ = v_fallback(extra_d, [extra_r*2, 0]);

    size=[d_,d_,d_];
    extra_size=[extra_d_,extra_d_,extra_d_];
    size_align(size=size, extra_size=extra_size, align=align, extra_align=extra_align, orient=orient, orient_ref=orient_ref, roll=roll, extra_roll=extra_roll, extra_roll_orient=extra_roll_orient)
    sphere(d=d_+extra_d_);
}

module cylindera(
        h=10,
        r=U,
        r1=U,
        r2=U,
        d=U,
        d1=U,
        d2=U,
        align=N,
        orient=Z,
        extra_h=0,
        extra_r=U,
        extra_d=U,
        extra_align=N,
        round_r=0,
        debug=false
        )
{
    pi=3.1415926536;

    d1_ = v_fallback(d1, [r*2, r1*2]);
    d2_ = v_fallback(d2, [r*2, r2*2]);

    r1_ = v_fallback(r1, [d1_/2, d/2, r]);
    r2_ = v_fallback(r2, [d2_/2, d/2, r]);

    r_max = v_fallback(r, [max(r1_,r2_)]);

    extra_r_ = v_fallback(extra_r, [extra_d/2, 0]);

    if(debug)
    {
        echo(useDia, h, r_, r1_, r2_, extra_r_, align);
    }

    size_align(size=[r_max*2,r_max*2,h], extra_size=[extra_r_*2, extra_r_*2, extra_h], orient=orient, orient_ref=Z, align=align, extra_align=extra_align)
    {
        if(round_r>0)
        {
            rcylindera(h=h+extra_h, r1=r1_+extra_r_, r2=r2_+extra_r_, round_r=round_r);
        }
        else
        {
            cylinder(h=h+extra_h, r1=r1_+extra_r_, r2=r2_+extra_r_, center=true);
        }
    }
}

module torus(r=U, radius=5, radial_width, align=N, orient=Z)
{
    r_ = fallback(r, radius);
    size_align(size=[r_*2+radial_width*2, r_*2+radial_width*2, radial_width*2], align=align, orient=orient)
    rotate_extrude()
    translate(r_*X)
    circle(radial_width);
}

module rcylindera(
        h=10,
        r=U,
        r1=U,
        r2=U,
        d=U,
        d1=U,
        d2=U,
        align=N,
        orient=Z,
        extra_h=0,
        extra_r=U,
        extra_d=U,
        extra_align=N,
        round_r=1,
        debug=false
        )
{
    d1_ = v_fallback(d1, [r*2, r1*2]);
    d2_ = v_fallback(d2, [r*2, r2*2]);

    r1_ = v_fallback(r1, [d1_/2, d/2, r]);
    r2_ = v_fallback(r2, [d2_/2, d/2, r]);

    r_max = v_fallback(r, [max(r1_,r2_)]);

    h_ = h+extra_h;

    extra_r_ = v_fallback(extra_r, [extra_d/2, 0]);

    assert(r1_ != U);
    assert(r2_ != U);
    assert(extra_r_ != U);

    if(debug)
    {
        echo(useDia, h, r_, r1_, r2_, extra_r_, align);
    }

    size_align(size=[r_max*2,r_max*2,h], extra_size=[extra_r_*2, extra_r_*2, extra_h], orient=orient, orient_ref=Z, align=align, extra_align=extra_align)
    {
        if($preview_mode || round_r == 0)
        {
            cylindera(h=h_, r1=r1_+extra_r_, r2=r2_+extra_r_);
        }
        else
        {
            r_ = [r1_+extra_r_/2,r2_+extra_r_/2];

            hull()
            {
                for(z=[-1,1])
                translate([0, 0, z*(-h_/2)])
                {
                    r__=z!=-1?r_[0]:r_[1];
                    torus(radius=r__-round_r, radial_width=round_r, align=z*Z);
                }
            }
        }
    }
}

function rounded_rectangle_profile(size=[1,1],r=1,fn=$fn) = [
for (index = [0:fn-1])
let(a = index/fn*360)
r * [cos(a), sin(a)]
+ sign_x(index, fn) * [size[0]/2-r,0]
+ sign_y(index, fn) * [0,size[1]/2-r]
];

function sign_x(i,n) =
i < n/4 || i > n-n/4  ?  1 :
i > n/4 && i < n-n/4  ? -1 :
    0;

function sign_y(i,n) =
i > 0 && i < n/2  ?  1 :
i > n/2 ? -1 :
    0;

// From Obiscad
//----------------------------------------------------------
//--  Draw a point in the position given by the vector p  
//----------------------------------------------------------
module point(p, r=0.7, fn)
{
    translate(p)
    sphere(r=r);
}

//------------------------------------------------------------------
//-- Draw a vector poiting to the z axis
//-- This is an auxiliary module for implementing the vector module
//--
//-- Parameters:
//--  l: total vector length (line + arrow)
//--  l_arrow: Vector arrow length
//--  mark: If true, a mark is draw in the vector head, for having
//--    a visual reference of the rolling angle
//------------------------------------------------------------------
module vectorz(l=10, l_arrow=4, mark=true)
{
  //-- vector body length (not including the arrow)
  lb = l - l_arrow;

  //-- The vector is locatead at 0,0,0
  translate([0,0,lb/2])
  union() {

    //-- Draw the arrow
    translate([0,0,lb/2])
      cylindera(r1=2/2, r2=0.2, h=l_arrow);

    //-- Draw the mark
    if (mark) {
      translate([0,0,lb/2+l_arrow/2])
      translate(X)
        cubea([2,0.3,l_arrow*0.8]);
    }

    //-- Draw the body
    cylindera(r=1/2, h=lb, align=-Z);
  }

  //-- Draw a sphere in the vector base
  spherea(r=1/2, align=-Z);
}

// From Obiscad,
//---------------------------------------------------------------------------
//-- Draw a vector
//--
//-- There are two modes of drawing the vector
//-- * Mode 1: Given by a cartesian point(x,y,z). A vector from the origin
//--           to the end (x,y,z) is drawn. The l parameter (length) must 
//--           be 0  (l=0)
//-- * Mode 2: Give by direction and length
//--           A vector of length l pointing to the direction given by
//--           v is drawn
//---------------------------------------------------------------------------
//-- Parameters:
//--  v: Vector cartesian coordinates
//--  l: total vector length (line + arrow)
//--  l_arrow: Vector arrow length
//    mark: If true, a mark is draw in the vector head, for having
//--    a visual reference of the rolling angle
//---------------------------------------------------------------------------

module vector(v, l=4, l_arrow=2, mark=false)
{
  //-- Get the vector length from the coordinates
  mod = v_mod(v);

  //-- The vector is very easy implemented by means of the orientate
  //-- operator:
  //--  orientate(v) vectorz(l=mod, l_arrow=l_arrow)
  //--  BUT... in OPENSCAD 2012.02.22 the recursion does not
  //--    not work, so that if the user use the orientate operator
  //--    on a vector, openscad will ignore it..
  //-- The solution at the moment (I hope the openscad developers
  //--  implement the recursion in the near future...)
  //--  is to repite the orientate operation in this module

  //---- SAME CALCULATIONS THAN THE ORIENTATE OPERATOR!
  //-- Calculate the rotation axis

  vref = Z;
  raxis = v_cross(vref,v);

  //-- Calculate the angle between the vectors
  ang = v_anglev(vref,v);

  raxis_=ang==180&&raxis==N?X:raxis;

  //-- orientate the vector
  //-- Draw the vector. The vector length is given either
  //--- by the mod variable (when l=0) or by l (when l!=0)
  if (l==0)
    rotate(a=ang, v=raxis_)
      vectorz(l=mod, l_arrow=l_arrow, mark=mark);
  else
    rotate(a=ang, v=raxis_)
      vectorz(l=l, l_arrow=l_arrow, mark=mark);

}

// From Obiscad,
//--------------------------------------------------------------------
//-- Draw a connector
//-- A connector is defined a 3-tuple that consist of a point
//--- (the attachment point), and axis (the attachment axis) and
//--- an angle the connected part should be rotate around the 
//--  attachment axis
//--
//--- Input parameters:
//--
//--  Connector c = [p , n, ang] where:
//--
//--     p : The attachment point
//--     v : The attachment axis
//--   ang : the angle
//--------------------------------------------------------------------
module connector(c)
{
  //-- Get the three components from the connector
  p = c[0];
  v = c[1];
  ang = c[2];

  //-- Draw the attachment poing
  color("Gray") point(p);

  //-- Draw the attachment axis vector (with a mark)
  translate(p)
    rotate(a=ang, v=v)
    color("Gray") vector(v=v_unitv(v)*6, l_arrow=2, mark=true);
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
module pie_slice(r, start_angle, end_angle, h, orient=Z, align=N)
{
    size_align(size=[r*2, r*2, h], orient=orient, orient_ref=Z, align=align)
    linear_extrude(h)
    {
        pie_slice_shape(r, start_angle, end_angle);
    }
}

module hollow_cylinder(d=10, thickness=1, h=10, taper=false, taper_h=U, orient=Z, align=N)
{
    outer_d = d+thickness/2;
    inner_d = d-thickness/2;
    taper_h = taper_h == U ? min(h/4, (outer_d-inner_d)/2) : max(taper_h,h/2);
    taper_ = taper && taper_h > 0;
    size_align(size=[outer_d, outer_d, h], orient=orient, align=align);
    difference()
    {
        union()
        {
            cylindera(h=h-(taper_?taper_h*2:0), d=outer_d, orient=Z, align=N);
            if(taper_)
            {
                for(z=[-1,1])
                translate([0,0,z*(h/2-taper_h)])
                mirror([0,0,z==-1?1:0])
                cylindera(d1=outer_d, d2=outer_d-inner_d/4, h=taper_h, align=Z);
            }
        }
        if(taper_)
        {
            for(z=[-1,1])
            translate([0,0,z*(h/2-taper_h)])
            mirror([0,0,z==-1?1:0])
            cylindera(d1=inner_d, d2=outer_d, h=taper_h+.1, align=Z, extra_h=.2);

            // override fn for inner cylinder cut, to ensure same fragments as taper
            // this ensures cleaner mesh
            fn = fn_from_d(d=outer_d);
            cylindera(h=h+.2+taper_h, d=inner_d, orient=Z, align=N, $fn=fn);
        }
        else
        {
            cylindera(h=h, d=inner_d, orient=Z, align=N, extra_h=.4);
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
module triangle(o_len, a_len, depth, align=N, orient=Z)
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
module rtriangle(o_len, a_len, depth, round_r=2, align=N, orient=Z)
{
    size = [a_len-round_r, depth-round_r, o_len-round_r];
    r_x = round_r;
    r_y = round_r;
    r_z = -round_r;

    hyp = pythag_hyp(o_len,a_len);
    a_z = atan(a_len/o_len);

    translate([0,0,size[2]+2])
    color(X)
    rotate([90,90,0])
    pie_slice(r=2, start_angle=0, end_angle=a_z, h=depth);

    /*translate([size[0]+4,0,0])*/
    /*color(X)*/
    /*rotate([90,90,0])*/
    /*pie_slice(r=2, start_angle=90, end_angle=90+a_z, h=depth);*/

    size_align(size=size, align=align, orient=orient)
    /*hull()*/
    for(x=[-(size[0]/2)+round_r,(size[0]/2)-r_x])
    for(y=[-(size[1]/2)+round_r,(size[1]/2)-r_y])
    for(z=[-(size[2]/2)+round_r,(size[2]/2)-r_z])
    translate([x,y,z])
    if(x<=1 || z<=1)
    sphere(r=round_r);
}

module teardrop(r, d, h=10, truncate=1, align=N, orient=Y, roll=0)
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

    size_align(size=[d,d,h], align=align, orient=orient, orient_ref=Z, roll=roll)
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
    all_axes()
    translate($axis*r*2)
    color($color)
    teardrop(r=r, h=20, orient=$axis, align=$axis);
}

// test cubea
if(false)
{
    w=5*mm;
    h=2*mm;
    all_axes()
    color($color)
    cubea([w,w,h], orient=$axis, align=$axis*3);
}
/**
/*debug();*/

module debug()
{
    $fs = 0.1;
    $fa = 1;

    /*triangle_a(45, 5, 5);*/
    /*triangle(15, 10, 5, align=[1,1,1], orient=-Z);*/
    /*triangle(15, 10, 5, align=[1,1,1], orient=Z);*/

    triangle(10, 30, 5, align=[1,1,1], orient=Z);
    translate([0,-10,0])
    rtriangle(10, 30, 5, align=[1,1,1], orient=Z);
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
    stack(axis=X, dist=15)
    {
        hollow_cylinder(thickness=5, h=10, taper=false, orient=Z, align=Z);
        hollow_cylinder(thickness=5, h=10, taper=true, orient=Z, align=Z);
    }

    /*cylindera(d=10, h=10, orient=Z, align=Z);*/
    /*translate([10,0,0])*/
    /*{*/
    /*hollow_cylinder(d=10, thickness=4, h=10, taper=true, taper_h=.5, orient=Z, align=Z);*/
    /*cylindera(d=8, h=10, orient=Z, align=Z);*/
    /*}*/

    /*%pie_slice(r=10, start_angle=-30, end_angle=270, h=10);*/

    /*cubea([10,10,10],X);*/
    /*%cubea([10,10,10],X,[5,5,5],[1,1,1]);*/

    /*%cubea([10,10,10],[-1,0,1]);*/
    /*%cubea([10,10,10],[-1,0,1],[1,1,1],[-1,0,1]);*/
    /*%cylindera(h=10, r=10/2, align=[-1,1,1], extra_r=5/2, extra_h=2, extra_align=[-1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[-1,1,1], extra_d=5, extra_h=2, extra_align=[-1,1,1], $fn=100);*/
    /*%cylindera(h=10, d=10, align=[1,1,1], extra_d=15, extra_h=2, extra_align=[1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=[1,-1,1], extra_d=5, extra_h=2, extra_align=[-1,-1,1], $fn=100);*/
    /*%cylindera(h=10, d=10, align=[1,1,1], extra_d=5, extra_h=2, extra_align=[1,1,1], $fn=100);*/

    /*%cylindera(h=10, d=10, align=X, extra_d=10);*/

    /*hull_pairwise()*/
    /*sphere(30/2);*/

    /*translate([30,0,0])*/
    /*rcubea(s=[35,35,35], round_r=10);*/
    /*rcubea(s=[35,35,35], align=-Y);*/

    /*translate([60,0,0])*/
    /*sphere(30/2);*/


    cylindera(h=20, r=5*mm, align=Y, orient=Z, $fn=100);

/*size_align(size=[5,5,20], orient=Y, orient_ref=Z)*/
/*size_align(size=[5,5,20], orient=Y, orient_ref=Y, align=Y)*/
/*size_align(size=[5,20,5], orient=Z, orient_ref=Y, align=N)*/
/*rotate([90,0,0])*/
/*cylinder(d=5, h=20, center=true);*/

/*cylindera(d=10, h=10, orient=Y, align=Z);*/
}

if(false)
{
    /*cubea();*/
    /*rcubea(size=[10,10,10]);*/

    is_build = true;
    $fs = is_build ? 0.5 : 2;
    $fa = is_build ? 4 : 12;

    stack(axis=X, dist=15)
    {
        cylindera(h=10,r=5);

        rcylindera(h=10,r=5);


        rcubea([10,10,10]);
    }
}


if(false)
{
    r=5*mm;
    all_axes()
    translate($axis*r*2)
    color($color)
    /*orient(axis=$axis, axis_ref=Z)*/
    /*translate(Z*10)*/
    /*rcylindera(r1=5, r2=3, h=10);*/
    {
        rcylindera(h=20, extra_d = 1*mm, r1=r, r2=r/2, align=$axis, orient=$axis, extra_h=r, extra_align=-$axis, $fn=16); /*cylindera(h=20, round_r=1, extra_r = 2*mm, r1=r, r2=r/2, align=$axis, orient=$axis, extra_h=r, extra_align=-$axis, $fn=16);*/
        cylindera(h=20, extra_d = 1*mm, r1=r, r2=r/2, align=$axis, orient=$axis, extra_h=r, extra_align=-$axis, $fn=16); /*cylindera(h=20, round_r=1, extra_r = 2*mm, r1=r, r2=r/2, align=$axis, orient=$axis, extra_h=r, extra_align=-$axis, $fn=16);*/
    }

}

if(false)
{
    all_axes()
    translate($axis*r*2)
    color($color)
    {
        orient(axis=$axis, axis_ref=Z)
        hull()
        {
            cubea(size=[5,8,7]);
            translate(5*Z)
            cubea(size=[2,2,2]);
        }
    }
}

if(false)
{
    stack(dist=50, axis=Y)
    {
        stack(dist=10, axis=-Z)
        {
            /*cylindera(orient=-Z, align=-Z);*/
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=Z, align=-Z);
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=-Z, align=Z);
            /*pie_slice(r=30, h=5, start_angle=-90, end_angle=180, align=-Z);*/
            /*pie_slice(r=30, h=5, start_angle=90, end_angle=270, align=-Z);*/
            /*pie_slice(r=30, h=5, start_angle=0, end_angle=270, align=-Z);*/
        }

        stack(dist=10, axis=Y)
        {
            /*cylindera(orient=Y, align=Y);*/
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=-Y, align=Y);
            pie_slice(r=30, h=5, start_angle=0, end_angle=120, orient=Y, align=Y);
            pie_slice(r=30, h=5, start_angle=-90, end_angle=180, orient=Y, align=Y);
            pie_slice(r=30, h=5, start_angle=90, end_angle=270, orient=Y, align=Y);
            pie_slice(r=30, h=5, start_angle=0, end_angle=270, orient=Y, align=Y);
        }
    }
}

if(false)
{
    /*$fs = 0.5;*/
    /*$fa = 4;*/

    r=5;
    hull()
    {
        stack(dist=10, axis=-Z)
        {
            rcylindera(r=r, h=r*2, orient=Y, align=Y);
            rcylindera(r=r, h=r*2, orient=Y, align=Y);
        }

        rcylindera(r=5, h=r, orient=X, align=Y+X+Z);
    }
}
