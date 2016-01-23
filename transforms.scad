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

module stack(dist=10, distances=undef)
{
    if(dist == undef && distances != undef)
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
    else if(dist != undef && distances == undef)
    {
      for (i = [0 : $children-1])
          translate([ dist*i, 0, 0 ]) children(i);
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

module hull_pairwise()
{
    for (i= [1:1:$children-1])
    {
        hull()
        {
            children(i-1);
            children(i);
        }
    }
}

