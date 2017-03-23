include <units.scad>
include <system.scad>

use <misc.scad>
use <transforms.scad>
use <shapes.scad>
use <screws.scad>
include <bearing-linear-data.scad>
include <thread-data.scad>

module linear_bearing(part, bearing, align=N, orient=Z, offset_flange=false)
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

    flange_screw_len=12*mm;

    flange_offset = offset_flange ? -flange_h : 0;
    h = get(LinearBearingLength,bearing);
    d = get(LinearBearingInnerDiameter, bearing);
    D = get(LinearBearingOuterDiameter, bearing);
    s = [width_x, width_y, h];
    if(part==U)
    {
        difference()
        {
            linear_bearing(part="pos", bearing=bearing, align=align, orient=orient, offset_flange=offset_flange);
            linear_bearing(part="neg", bearing=bearing, align=align, orient=orient, offset_flange=offset_flange);
        }
        %linear_bearing(part="vit", bearing=bearing, align=align, orient=orient, offset_flange=offset_flange);
    }
    else if(part=="pos")
    size_align(size=s, align=align, orient=orient)
    translate(Z*flange_offset)
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
    size_align(size=s, align=align, orient=orient)
    translate(Z*flange_offset)
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
                hollow_cylinder(d=D-clip_groove/2+.01, thickness=clip_groove, h=clip_groove, taper=false, orient=Z, align=-z);
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
                screw_cut(thread=ThreadM4, h=flange_screw_len, orient=Z, align=Z);
            }
            else if(flange_d_cut != U)
            {
                // LMH
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*get(LinearBearingFlangeCutMountHoleDist, bearing)/2)
                translate(x*X*get(LinearBearingFlangeCutMountHoleDistSide, bearing)/2)
                screw_cut(thread=ThreadM4, h=flange_screw_len, orient=Z, align=Z);
            }
            else if(flange_d != U)
            {
                // LMF
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*flange_pcd/2*sqrt(2)/2)
                translate(x*X*flange_pcd/2*sqrt(2)/2)
                screw_cut(thread=ThreadM4, h=flange_screw_len, orient=Z, align=Z);
            }
        }
    }
}

module linear_bearing_mount(part=part, bearing, extra_h=0, override_h=U, ziptie_type=[2*mm, 3*mm], ziptie_bearing_distance=3*mm, tolerance=.1*mm, align=N, orient=Z, ziptie_dist=U, with_zips=true, offset_flange=false, mount_dir_align=X, mount_style="closed")
{
    ziptie_thickness = ziptie_type[0];
    ziptie_width = ziptie_type[1]+0.6*mm;

    ziptie_dist_ = fallback(ziptie_dist, get(LinearBearingClipsDistance,bearing)/2);

    clip_dist = get(LinearBearingClipsDistance, bearing);

    h = fallback(override_h, get(LinearBearingLength,bearing)) + extra_h;
    d = get(LinearBearingInnerDiameter, bearing);
    D = get(LinearBearingOuterDiameter, bearing);

    flange_h = fallback(get(LinearBearingFlangeThickness, bearing),0);

    // for all kinds of flanges
    flange_d = get(LinearBearingFlangeDiameter,bearing);

    // only for square flange
    flange_side = get(LinearBearingFlangeSide,bearing);

    // only for cut flanges
    flange_d_cut = get(LinearBearingFlangeCutDiameter,bearing);

    flange_pcd = get(LinearBearingFlangePitchCircleDiameter,bearing);

    flange_screw_len=12*mm;
    flange_offset = offset_flange ? -flange_h : 0;

    support_wall_thickness = 2.5*mm;
    if(part==U)
    {
        difference()
        {
            linear_bearing_mount(part="pos", bearing=bearing, extra_h=extra_h, override_h=override_h, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, tolerance=tolerance, align=align, orient=orient, ziptie_dist=ziptie_dist, with_zips=with_zips, offset_flange=offset_flange, mount_dir_align=mount_dir_align, mount_style=mount_style);
            linear_bearing_mount(part="neg", bearing=bearing, extra_h=extra_h, override_h=override_h, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, tolerance=tolerance, align=align, orient=orient, ziptie_dist=ziptie_dist, with_zips=with_zips, offset_flange=offset_flange, mount_dir_align=mount_dir_align, mount_style=mount_style);
        }
        %linear_bearing_mount(part="vit", bearing=bearing, extra_h=extra_h, override_h=override_h, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, tolerance=tolerance, align=align, orient=orient, ziptie_dist=ziptie_dist, with_zips=with_zips, offset_flange=offset_flange, mount_dir_align=mount_dir_align, mount_style=mount_style);
    }
    else if(part=="pos")
    size_align(size=[D,D,h], align=align, orient=orient)
    {
        translate(-Z*h/2)
        {
            // z axis bearing support
            if(mount_style=="open")
            {
                intersection()
                {
                    D_=D+2*support_wall_thickness;
                    h_ = h+flange_offset;
                    rcylindera(h=h_, d=D_, orient=Z, align=Z);
                    rcubea(size=[D_,D_,h_], orient=Z, align=Z+mount_dir_align);
                }
            }
            else if(mount_style=="closed")
            {
                D_=D+2*support_wall_thickness;
                h_ = h+flange_offset;
                rcylindera(h=h_, d=D_, orient=Z, align=Z);
            }

            // support for clips
            if(clip_dist != U)
            {
                translate(Z*h/2)
                for(z=[-1,1])
                translate(z*Z*clip_dist/2)
                hollow_cylinder(d=D-clip_groove/2+.01, thickness=clip_groove, h=clip_groove, taper=false, orient=Z, align=-z);
            }

            // support for flange mount
            if(flange_side != U)
            {
                // LMK
                // screw cut
                for(x=[-1,1])
                for(y=[-1,1])
                translate(y*Y*flange_pcd/2*sqrt(2)/2)
                translate(x*X*flange_pcd/2*sqrt(2)/2)
                rcylindera(d=1.5*get(LinearBearingFlangeMountingSize,bearing), h=flange_screw_len, orient=Z, align=Z);
            }
            else if(flange_d_cut != U)
            {
                // LMH
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*get(LinearBearingFlangeCutMountHoleDist, bearing)/2)
                translate(x*X*get(LinearBearingFlangeCutMountHoleDistSide, bearing)/2)
                rcylindera(d=1.5*get(LinearBearingFlangeMountingSize,bearing), h=flange_screw_len, orient=Z, align=Z);
            }
            else if(flange_d != U)
            {
                // LMF
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*flange_pcd/2*sqrt(2)/2)
                translate(x*X*flange_pcd/2*sqrt(2)/2)
                rcylindera(d=1.5*get(LinearBearingFlangeMountingSize,bearing), h=flange_screw_len, orient=Z, align=Z);
            }
        }
    }
    else if(part=="neg")
    size_align(size=[D,D,h], align=align, orient=orient)
    translate(Z*flange_offset)
    translate(-Z*.001)
    {
        // Main bearing cut
        cylindera(h=h+tolerance, d=D+tolerance, orient=Z);

        if(mount_style=="open")
        {
            if(with_zips)
            {
                for(z=[-1,1])
                translate([0,0,z*ziptie_dist_ - z*1/2])
                hollow_cylinder(
                    d=D+ziptie_bearing_distance+ziptie_thickness,
                    thickness = ziptie_thickness*2,
                    h = ziptie_width,
                    taper=false,
                    orient=Z,
                    align=N
                    );
            }
        }

        // for linear rod
        cylindera(d=d+2*mm, h=1000, orient=Z);

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
                hollow_cylinder(d=D-clip_groove/2+.01, thickness=clip_groove, h=clip_groove, taper=false, orient=Z, align=-z);
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
                screw_cut(thread=ThreadM4, h=flange_screw_len, orient=Z, align=Z);
            }
            else if(flange_d_cut != U)
            {
                // LMH
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*get(LinearBearingFlangeCutMountHoleDist, bearing)/2)
                translate(x*X*get(LinearBearingFlangeCutMountHoleDistSide, bearing)/2)
                screw_cut(thread=ThreadM4, h=flange_screw_len, orient=Z, align=Z);
            }
            else if(flange_d != U)
            {
                // LMF
                // screw cut
                for(y=[-1,1])
                for(x=[-1,1])
                translate(y*Y*flange_pcd/2*sqrt(2)/2)
                translate(x*X*flange_pcd/2*sqrt(2)/2)
                screw_cut(thread=ThreadM4, h=flange_screw_len, orient=Z, align=Z);
            }
        }

    }
    else if(part=="vit")
    size_align(size=[D,D,h], align=align, orient=orient)
    translate(Z*flange_offset)
    {
        if($show_vit)
        {
            linear_bearing(bearing=bearing);

            if(mount_style=="open")
            for(z=[-1,1])
            translate([0,0,z*ziptie_dist_])
            {
                hollow_cylinder(
                    d=D+ziptie_bearing_distance+ziptie_thickness,
                    thickness = ziptie_thickness,
                    h = ziptie_width,
                    taper=false,
                    orient=Z,
                    align=-z*Z
                    );
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
        {
            linear_bearing(bearing=bearing, align=Z);
            translate((v_width[i]/2 + 3*mm)*-Y)
            rotate(-90*Z)
            text(get(LinearBearingModel, bearing), size=v_width[i]*.8, valign="center", halign="left");

            translate((v_width[i] + 10*mm)*Y)
            linear_bearing_mount(bearing=bearing, align=Z);
        }
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

