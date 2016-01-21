use <misc.scad>

// translate children 
module lineup(arr=undef)
{
    /*echo(arr);*/
    /*echo($children);*/
    if($children>0)
    {
        for (i = [0 : $children-1])
            translate(arr[i]) children(i);
    }
}

module stack(separations)
{
    union()
    {
        for (i = [0:len(separations)-1])
        {
            offset = v_sum(separations,i);
            /*echo("i",i,"offset",offset);*/
            translate ([0,0,offset])
            {
                child(i);
            }
        }
    }
}

module orient(zaxes, roll=0)
{
    zaxes = len(zaxes.x) == undef && zaxes.x != undef? [zaxes] : zaxes;
    for(zaxis=zaxes)
    {
        rotate(_orient_angles(zaxis))
        /*rotate(roll*z)*/
            children();
    }
}

module size_align(size=[10,10,10], align=[0,0,0], orient=[0,0,1])
{
    bounds = _rotate_matrix(_orient_angles(orient)) * [size.x,size.y,size.z,1];
    t=hadamard(align, [abs(bounds.x/2),abs(bounds.y/2),abs(bounds.z/2)]);
    translate(t)
    {
        orient(orient)
        {
            children();
        }
    }
}

module cubea(size=[10,10,10], align=[0,0,0], extrasize=[0,0,0], extrasize_align=[0,0,0])
{
    size_align(extrasize,extrasize_align)
    {
        size_align(size,align)
        {
            cube(size+extrasize, center=true);
        }
    }
}

module cuberounda(size=[10,10,10], facets=32, rounding_radius=1, align=[0,0,0], extrasize=[0,0,0], extrasize_align=[0,0,0])
{
    size_align(extrasize,extrasize_align)
    {
        size_align(size,align)
        {
            cuberound(size=size+extrasize, facets=facets, rounding_radius=rounding_radius);
        }
    }
}

module cuberound(size=[20,20,20], rounding_radius=1)
{
    hull()
    for(x=[-(size[0]/2-rounding_radius),(size[0]/2-rounding_radius)])
    for(y=[-(size[1]/2-rounding_radius),(size[1]/2-rounding_radius)])
    for(z=[-(size[2]/2-rounding_radius),(size[2]/2-rounding_radius)])
    translate([x,y,z])
    sphere(r=rounding_radius);
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
        extra_align=[0,0,1],
        debug=false
        )
{
    pi=3.1415926536;

    useDia = r == undef && (r1 == undef && r2 == undef);

    r1_ = useDia?((d1==undef?undef:d1)/2):r1;
    r2_ = useDia?((d2==undef?undef:d2)/2):r2;
    r_= useDia?d/2:(r==undef?0:r);
    r1r2max = max(r1,r2) == undef ? max(d1,d2)/2 : max(r1,r2);
    r__ = r_==undef? r1r2max : r_;
    extra_r_ = useDia?((extra_d==undef?0:extra_d)/2):((extra_r==undef)?0:extra_r);

    sizexy=r__*2;
    extra_sizexy=extra_r_*2;

    // some orient hax here to properly support extra_align
    orient(-orient)
    size_align([extra_sizexy,extra_sizexy,extra_h], align=extra_align, orient=orient)
    orient(orient)
    {
        if(debug)
        {
            echo(useDia, h, r_, r1_, r2_, extra_r_, align);
        }

        // some orient hax here to properly support extra_align
        orient(-orient)
        size_align([sizexy,sizexy,h], align=align, orient=orient)
        {
            cylinder(h=h+extra_h, r=r_+extra_r_, r1=r1_, r2=r2_, center=true);
        }
    }
}

module pie_slice_shape(r, start_angle, end_angle) {
    R = r * sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    if(end_angle > start_angle)
    {
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
}

module pie_slice(r, start_angle, end_angle, h) 
{
    linear_extrude(h)
    {
        pie_slice_shape(r, start_angle, end_angle);
    }
}

module hollow_cylinder(d=10, thickness=1, h=10, taper=false, orient=[0,0,1], align=[0,0,0])
{
    outer_d = d+thickness/2;
    inner_d = d-thickness/2;
    size_align(size=[outer_d, outer_d, h], orient=orient, align=align)
    difference()
    {
        hull()
        {
            taper_h = outer_d/2;
            if(taper)
            {
                for(z=[-1,1])
                translate([0,0,z*h/2])
                mirror([0,0,z==-1?1:0])
                difference()
                {
                    cylindera(d1=outer_d, d2=0, h=taper_h, align=[0,0,1]);
                    cylindera(d1=inner_d, d2=inner_d*2, h=taper_h, align=[0,0,1]);
                }
            }
        }

        cylindera(h=h+.2, d=inner_d, orient=[0,0,1], align=[0,0,0]);

    }
}

/*hollow_cylinder(thickness=2, h=9, taper=true, orient=[0,0,1], align=[0,0,1]);*/

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

