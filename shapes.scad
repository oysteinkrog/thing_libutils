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


module cylindera(h=10, r=undef, r1=undef, r2=undef, d=undef, d1=undef, d2=undef, align=[0,0,0], extra_h=0,extra_r=undef,extra_d=undef,extra_align=[0,0,0])
{
    extra_r_=(extra_r==undef?0:extra_r);
    extra_d_=(extra_d==undef?0:extra_d);
    extra_sizexy=extra_r_*2 + extra_d_;
    size_align([extra_sizexy,extra_sizexy,extra_h],extra_align)
    {
        r_=(r==undef?0:r);
        d_=(d==undef?0:d);
        sizexy=r_*2 + d_;
        size_align([sizexy,sizexy,h],align)
        {
            cylinder(h=h+extra_h, r=r+extra_r_, r1=r1, r2=r2, d=d+extra_d_, d1=d1, d2=d2, center=true);
        }
    }
}


module fncylinder(r, r2, d, d2, h, fn, center=false, enlarge=0, fnr=0.4){
    translate(center==false?[0,0,-enlarge]:[0,0,-h/2-enlarge]) {
        if (fn==undef) {
            if (r2==undef && d2==undef) {
                cylinder(r=r?r:d?d/2:1,h=h+enlarge*2,$fn=floor(2*(r?r:d?d/2:1)*PI/fnr));
            } else {
                cylinder(r=r?r:d?d/2:1,r2=r2?r2:d2?d2/2:1,h=h+enlarge*2,$fn=floor(2*(r?r:d?d/2:1)*PI/fnr));
            }
        } else {
            if (r2==undef && d2==undef) {
                cylinder(r=r?r:d?d/2:1,h=h+enlarge*2,$fn=fn);
            } else {
                cylinder(r=r?r:d?d/2:1,r2=r2?r2:d2?d2/2:1,h=h+enlarge*2,$fn=fn);
            }
        }
    }
}

// specify segment length with fnr, $fn not needed but if desired use fn instead but if desired use fn instead
module fncylindera(
        h=10,
        r=undef,
        r1=undef,
        r2=undef,
        d=undef,
        d1=undef,
        d2=undef,
        align=[0,0,0],
        extra_h=0,
        extra_r=undef,
        extra_d=undef,
        extra_align=[0,0,0],
        fn,
        fnr=0.4,
        debug=false
        )
{
    pi=3.1415926536;

    useDia = r == undef && (r1 == undef && r2 == undef);

    r_= useDia?d/2:(r==undef?0:r);
    r1_ = useDia?((d1==undef?undef:d1)/2):r1;
    r2_ = useDia?((d2==undef?undef:d2)/2):r2;
    extra_r_ = useDia?((extra_d==undef?0:extra_d)/2):((extra_r==undef)?0:extra_d/2);

    extra_sizexy=extra_r_*2;

    size_align([extra_sizexy,extra_sizexy,extra_h],extra_align)
    {

        fn_=fn==undef?(floor(2*(r_+extra_r_)*pi/fnr)):fn;

        if(debug)
            echo(useDia, h, r_, r1_, r2_, extra_r_, align, fn_);

        sizexy=r_*2;
        size_align([sizexy,sizexy,h],align)
        {
            cylinder(h=h+extra_h, r=r_+extra_r_, r1=r1_, r2=r2_, center=true, $fn=fn_);
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
/*%cylindera(h=10, r=5, align=[-1,0,0], extra_r=5);*/
