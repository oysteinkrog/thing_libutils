include <units.scad>
include <system.scad>
include <transforms.scad>
include <shapes.scad>
include <screws.scad>
include <bearing-linear-data.scad>

module linear_bearing(bearing, part, align=N, orient=Z, offset_flange=false)
{
    model = get(LinearBearingModel, bearing);
    width_x = fallback(get(LinearBearingFlangeCutDiameter, bearing),LinearBearingOuterDiameter);
    width_y = fallback(get(LinearBearingFlangeDiameter, bearing),LinearBearingOuterDiameter);

    clip_dist = get(LinearBearingClipsDistance, bearing);
    clip_groove = get(LinearBearingClipsGrooveDepth, bearing);
    clip_dia = get(LinearBearingClipsDiameter, bearing);

    flange_h = fallback(get(LinearBearingFlangeThickness, bearing),0);

    // for all kinds of flanges
    flange_d = get(LinearBearingFlangeDiameter,bearing);

    // only for square flange
    flange_side = get(LinearBearingFlangeSide,bearing);

    // only for cut flanges
    flange_d_cut = get(LinearBearingFlangeCutDiameter,bearing);

    flange_pcd = get(LinearBearingFlangePitchCircleDiameter,bearing);

    t = offset_flange ? -Z*flange_h : 0;
    h = get(LinearBearingLength,bearing);
    d = get(LinearBearingInnerDiameter, bearing);
    D = get(LinearBearingOuterDiameter, bearing);
    s = [width_x, width_y, h];
    if(part==U)
    {
        difference()
        {
            linear_bearing(bearing=bearing, part="pos", align=align, orient=orient, offset_flange=offset_flange);
            linear_bearing(bearing=bearing, part="neg", align=align, orient=orient, offset_flange=offset_flange);
        }

    }
    else if(part=="pos")
    translate(t)
    size_align(size=s, align=align, orient=orient)
    {
        cylindera(h=h, d=D, orient=Z);

        // flange
        translate(-Z*h/2)
        {
            if(flange_side != U)
            {
                // LMK
                intersection()
                {
                    rcubea(size=[flange_side, flange_side, flange_h], orient=Z, align=Z, round_r=1);

                    rcubea(size=[flange_d, flange_d, flange_h], orient=Z, align=Z, round_r=1);
                }
            }
            else if(flange_d != U)
            {
                // LMH
                if(flange_d_cut != U)
                {
                    intersection()
                    {
                        rcylindera(h=flange_h, d=flange_d, orient=Z, align=Z, round_r=1);
                        rcubea(size=[get(LinearBearingFlangeCutDiameter, bearing), flange_d, flange_h], align=Z, round_r=1);
                    }
                }
                // LMF
                else if(flange_d != U)
                {
                    rcylindera(h=flange_h, d=flange_d, orient=Z, align=Z, round_r=1);
                }
            }
        }
    }
    else if(part=="neg")
    translate(t)
    size_align(size=s, align=align, orient=orient)
    {
        translate(-Z*h/2)
        {
            // inner bore cut
            cylindera(h=h, d=d, orient=Z, align=Z, extra_h=.2);

            // clips
            if(clip_dist != U)
            {
                translate(Z*h/2)
                for(z=[-1,1])
                translate(z*Z*clip_dist/2)
                hollow_cylinder(d=clip_dia, thickness=clip_groove, h=clip_groove, taper=false, orient=Z, align=-z);
            }

            // flange
            if(flange_side != U)
            {
                // LMK
                // screw cut
                for(x=[-1,1])
                for(y=[-1,1])
                translate(y*Y*flange_pcd/2*sqrt(2)/2)
                translate(x*X*flange_pcd/2*sqrt(2)/2)
                screw_cut(thread=ThreadM4, h=10*mm, orient=Z, align=Z);
            }
            else if(flange_d_cut != U)
            {
                // LMH
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*get(LinearBearingFlangeCutMountHoleDist, bearing)/2)
                translate(x*X*get(LinearBearingFlangeCutMountHoleDistSide, bearing)/2)
                screw_cut(thread=ThreadM4, h=10*mm, orient=Z, align=Z);
            }
            else if(flange_d != U)
            {
                // LMF
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*flange_pcd/2*sqrt(2)/2)
                translate(x*X*flange_pcd/2*sqrt(2)/2)
                screw_cut(thread=ThreadM4, h=10*mm, orient=Z, align=Z);
            }
        }
    }
}

// all
if(false)
{
    v_flangewidth = v_get(AllLinearBearing,LinearBearingFlangeDiameter);
    v_dia = v_get(AllLinearBearing,LinearBearingOuterDiameter);
    v_width = vv_fallback([v_flangewidth, v_dia]);
    dist_cumsum = v_cumsum(v_width, 0);
    for(i=[0:1:len(AllLinearBearing)-1])
    {
        bearing = AllLinearBearing[i];
        dist=dist_cumsum[i];
        translate(X*dist)
        linear_bearing(bearing=bearing, align=Z);
    }
}

if(false)
{
    stack(axis=X, dist=50*mm)
    {
        linear_bearing(bearing=LinearBearingLM6, align=Z);
        linear_bearing(bearing=LinearBearingLM6L, align=Z);
        linear_bearing(bearing=LinearBearingLMF8, align=Z);
        linear_bearing(bearing=LinearBearingLMF8L, align=Z);
        linear_bearing(bearing=LinearBearingLMK8, align=Z);
        linear_bearing(bearing=LinearBearingLMK8L, align=Z);
        linear_bearing(bearing=LinearBearingLMH12L, align=Z);
        linear_bearing(bearing=LinearBearingLMH16L, align=Z);
    }
}

