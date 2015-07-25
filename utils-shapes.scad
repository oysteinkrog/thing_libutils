module size_align(size=[10,10,10], align=[0,0,0])
{
    t=[align[0]*size[0]/2,align[1]*size[1]/2,align[2]*size[2]/2];
    /*echo(t);*/
    translate(t)
    {
        children();
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


/*cubea([10,10,10],[1,0,0]);*/
/*%cubea([10,10,10],[1,0,0],[5,5,5],[1,1,1]);*/

/*%cubea([10,10,10],[-1,0,1]);*/
/*%cubea([10,10,10],[-1,0,1],[1,1,1],[-1,0,1]);*/
/*%cylindera(h=10, r=10/2, align=[-1,1,1], extra_r=5/2, extra_h=2, extra_align=[-1,1,1], $fn=100);*/

/*%cylindera(h=10, d=10, align=[-1,1,1], extra_d=5, extra_h=2, extra_align=[-1,1,1], $fn=100);*/
/*%cylindera(h=10, d=10, align=[1,1,1], extra_d=15, extra_h=2, extra_align=[1,1,1], $fn=100);*/

/*%cylindera(h=10, d=10, align=[1,-1,1], extra_d=5, extra_h=2, extra_align=[-1,-1,1], $fn=100);*/
/*%cylindera(h=10, d=10, align=[1,1,1], extra_d=5, extra_h=2, extra_align=[1,1,1], $fn=100);*/

%cylindera(h=10, d=10, align=[1,0,0], extra_d=10);
%cylindera(h=10, r=5, align=[-1,0,0], extra_r=5);
