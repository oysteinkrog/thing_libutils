module size_align(size=[10,10,10], align=[0,0,0])
{
    translate([align[0]*size[0]/2,align[1]*size[1]/2,align[2]*size[2]/2])
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

/*cubea([10,10,10],[1,0,0]);*/
/*%cubea([10,10,10],[1,0,0],[5,5,5],[1,1,1]);*/
