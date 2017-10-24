include <system.scad>
include <misc.scad>
include <gears-data.scad>

// SPUR GEARS (all functions assume module/mm system!)
// From http://www.micro-machine-shop.com/module_gear_data.pdf
// Legend:
// M  Metric Module
// C  Circular Pitch (mm)
// DP Diametral Pitch
// N  Number of teeth
// OD Outside Diameter (mm)
// DP Diametral Pitch
// CP Circular Pitch
// A  Addendum
// WD Whole Depth

function spurgear_M_from_PD_N(PD,N) = PD/N;
function spurgear_M_from_C(C) = C/PI;
function spurgear_M_from_DP(DP) = 25.4/DP;
function spurgear_M_from_OD_N(OD, N) = OD/(N+2);

function spurgear_PD_from_M_N(M, N) = M*N;
function spurgear_PD_from_N_OD(N, OD) = (OD*N)/(N+2);
function spurgear_PD_from_OD_M(OD, M) = OD-2*M;

function spurgear_OD_from_M_N(M,N) = (N+2)*M;

function spurgear_DP_from_M(M) = 25.4/M;

function spurgear_CP_from_M(M) = M*PI;

function spurgear_A_from_M(M) = M;

/*function spurgear_WD_from_M(M) = let (DP = spurgear_DP_from_M(M)) DP>=20 ? (2.2/DP+.002) : 2.157*M;*/
function spurgear_WD_from_M(M) = 2.157*M;

function calc_gear_PD(gear) = get(GearMod,gear)*get(GearTeeth,gear);
function calc_gear_OD(gear) = spurgear_OD_from_M_N(get(GearMod,gear),get(GearTeeth,gear));

// CD = (PD1+PD1)/2
function calc_gears_center_distance(A, B) = (calc_gear_PD(A)+calc_gear_PD(B))/2;

if($test_mode)
{
    assert_v(spurgear_M_from_DP(48), 0.529167);

    echo(calc_gear_PD(gear_60t_mod05));
    echo(calc_gears_center_distance(gear_60t_mod05,gear_13t_mod05));

    for(i=[0:1:75])
    echo(i, spurgear_WD_from_M(i));
}
