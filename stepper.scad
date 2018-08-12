 // Some code from MCAD/stepper.scad
 // Originally by Hans Häggström, 2010.
 // Dual licenced under Creative Commons Attribution-Share Alike 3.0 and LGPL2 or later

include <system.scad>
include <units.scad>
include <materials.scad>
include <stepper-data.scad>
include <misc.scad>

use <transforms.scad>
use <shapes.scad>

/*test2();*/

module test()
{
    for (size = AllNemaSizes)
    {
        ty(size*100)
        stack(axis=X, dist=100)
        {
            motor(model=Nema34, size=size, dual_axis=true);
            motor(model=Nema23, size=size, dual_axis=true);
            motor(model=Nema17, size=size, dual_axis=true);
            motor(model=Nema14, size=size, dual_axis=true);
            motor(model=Nema11, size=size, dual_axis=true);
            motor(model=Nema08, size=size, dual_axis=true);
        }
    }
}

module test2()
{
    model = Nema17;
    size = NemaMedium;
    motor_mount(model=model, size=size, dual_axis=true);
}

function motorWidth(model) = get(NemaSideSize, model);
function motorLength(model, size=NemaMedium) = get(size, model);

module motor_mount(part=U, model, thickness, size=NemaMedium, dual_axis=false, orient=Z, align=U)
{
    assert(model!=U, "motor_mount(): model==U");
    assert(thickness!=U, "motor_mount(): thickness==U");
    assert(size!=U, "motor_mount(): size==U");

    length = get(size, model);
    side = get(NemaSideSize, model);
    extrSize = get(NemaRoundExtrusionHeight, model);
    extrRad = get(NemaRoundExtrusionDiameter, model) * 0.5;
    holeDist = get(NemaDistanceBetweenMountingHoles, model) * 0.5;
    holeRadius = get(NemaMountingHoleDiameter, model) * 0.5;

    s=[side, side, length];
    size_align(size=s, orient=orient, align=align)
    if(part==U)
    {
        material(Mat_Plastic)
        render()
        difference()
        {
            motor_mount(part="pos", model=model, thickness=thickness, size=size, dual_axis=dual_axis);
            motor_mount(part="neg", model=model, thickness=thickness, size=size, dual_axis=dual_axis);
        }

        if($show_vit)
        motor_mount(part="vit", model=model, thickness=thickness, size=size, dual_axis=dual_axis);
    }
    else if(part=="pos")
    {
        rcubea([side,side,thickness], align=Z);
    }
    else if(part=="neg")
    {
        cylindera(h=thickness+.1, r=extrRad, align=Z, extra_h=.1, extra_align=-Z);

        // main motor
        tz(-s.z)
        cubea(s, align=Z);

        // Bolt holes
        material(Mat_Aluminium)
        for(x=[-1,1])
        for(y=[-1,1])
        tx(x*holeDist)
        ty(y*holeDist)
        cylindera(h=thickness+.1, r=holeRadius, align=Z, extra_h=.1, extra_align=-Z);

    }
    else if(part=="vit")
    {
        motor(model=model, size=size, dualAxis=dual_axis, orient=Z);
    }
}

module motor(part=U, model, size=NemaMedium, dual_axis=false, orient=Z, align=U)
{
    assert(model!=U, "model == U");
    assert(size!=U, "size == U");
    length = get(size, model);

    side = get(NemaSideSize, model);
    cutR = get(NemaMountingHoleCutoutRadius, model);
    lip = get(NemaMountingHoleLip, model);
    holeDepth = get(NemaMountingHoleDepth, model);

    axleRadius = get(NemaAxleDiameter, model) * 0.5;

    extrSize = get(NemaRoundExtrusionHeight, model);
    extrRad = get(NemaRoundExtrusionDiameter, model) * 0.5;

    holeDist = get(NemaDistanceBetweenMountingHoles, model) * 0.5;
    holeRadius = get(NemaMountingHoleDiameter, model) * 0.5;

    mid = side / 2;

    roundR = get(NemaEdgeRoundingRadius, model);

    s=[side, side, length];
    size_align(size=s, orient=orient, align=align)
    if(part==U)
    {
        difference()
        {
            motor(part="pos", model=model, size=size, dual_axis=dual_axis);
            motor(part="neg", model=model, size=size, dual_axis=dual_axis);
        }
        motor(part="vit", model=model, size=size, dual_axis=dual_axis);

        motor_axle(model=model, size=size, dual_axis=dual_axis);
    }
    if(part=="echo")
    {
        echo(str("  Motor: Nema",get(NemaModel, model),", length= ",length,"mm, dual axis=",dual_axis));
    }
    else if(part=="pos")
    {
        material(Mat_BlackPaint)
        tz(-s.z)
        cubea(s, align=Z, extra_size=Z*extrSize, extra_align=Z);
    }
    else if(part=="neg")
    {
        // Axle hole
        material(Mat_Aluminium)
        cylindera(r=axleRadius+.2*mm, h=1000);

        // Corner cutouts
        if (lip > 0)
        material(Mat_BlackPaint)
        tz(-s.z)
        for(x=[-1,1])
        for(y=[-1,1])
        tx(x*side/2)
        ty(y*side/2)
        tz(-lip)
        cylindera(h=length, r=cutR, align=Z);

        // Rounded edges
        if (roundR > 0)
        material(Mat_BlackPaint)
        tz(-s.z)
        for(x=[-1,1])
        for(y=[-1,1])
        tx(x*side/2)
        ty(y*side/2)
        mirror([x>0?0:1,y>0?0:1,0])
        rz(45)
        cubea(size=[roundR, roundR*2, 4+length + extrSize+2], align=Z);

        // Bolt holes
        material(Mat_Aluminium)
        for(x=[-1,1])
        for(y=[-1,1])
        tx(x*holeDist)
        ty(y*holeDist)
        cylindera(h=holeDepth+.1*mm, r=holeRadius, align=-Z, extra_h=.1, extra_align=Z);

        // Grinded flat
        material(Mat_BlackPaint)
        difference()
        {
            cubea(size=[side+.1, side+.1, extrSize+.1], align=Z);
            cylindera(h=extrSize, r=extrRad, align=Z);
        }
    }
}

module motor_axle(model=Nema23, size=NemaMedium, dual_axis=false, orient=Z, align=U)
{
    assert(model!=U, "model == U");
    assert(size!=U, "size == U");
    length = get(size, model);

    axleLengthFront = get(NemaFrontAxleLength, model);
    axleLengthBack = get(NemaBackAxleLength, model);
    axleRadius = get(NemaAxleDiameter, model) * 0.5;

    extrSize = get(NemaRoundExtrusionHeight, model);

    roundR = get(NemaEdgeRoundingRadius, model);

    axleFlatDepth = get(NemaAxleFlatDepth, model);
    axleFlatLengthFront = get(NemaAxleFlatLengthFront, model);
    axleFlatLengthBack = get(NemaAxleFlatLengthBack, model);

    render()
    intersection()
    {
        material(Mat_Aluminium)
        tz(-length)
        cylindera(r=axleRadius, h=length+extrSize+axleLengthFront, align=Z, extra_h=dual_axis?axleLengthBack:0, extra_align=-Z);

        material(Mat_Aluminium)
        union()
        {
            tx(axleFlatDepth>0?-axleFlatDepth:0)
            cubea(size=[2*axleRadius, 2*axleRadius, axleLengthFront], align=Z);

            cubea(size=[2*axleRadius, 2*axleRadius, length+.4*mm], align=-Z, extra_size=Z*(extrSize+.4*mm), extra_align=Z);

            tx(axleFlatDepth>0?-axleFlatDepth:0)
            tz(-length)
            cubea(size=[2*axleRadius, 2*axleRadius, axleLengthBack], align=-Z);
        }
    }
}

