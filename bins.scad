include <utility.scad>
include <standard.scad>


// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 1; // .5
// number of bases along y-axis
gridy = 1; // .5
// number of bases along z-axis
gridz = 1;

/* [Half-grid] */
// Use half grid instead of regular grid
half_grid = true;

// ===== IMPLEMENTATION ===== //

dx = gridx * lbp_unit - 0.5;
dy = gridy * lbp_unit - 0.5;
dx_inside = dx - h_lip_1 - h_lip_3;
dy_inside = dy - h_lip_1 - h_lip_3;
th = gridz * lbi_h + lbi_lip;

hgrid = half_grid || (gridx * 10) % 10 > 0.1 || (gridy * 10) % 10 > 0.1;

gx = hgrid ? gridx * 2 : gridx;
gy = hgrid ? gridy * 2 : gridy;
l_bp = hgrid ? lbp_half_unit : lbp_unit;
l_bi = hgrid ? lbi_half_unit : lbi_unit;
difference(){
  union(){
    // Feets
    translate([-l_bp/2-gridx * lbp_half_unit,-l_bp/2-gridy * lbp_half_unit,0])
    grid(gx,gy,l_bp)
      bin_feet(l_bi);

    // Mainbody
    translate([0,0,h_feet_bin+0.1])
    rounded_rectangle(dx,dy,th-h_base_1-h_base_2-h_base_3,r_bin);
  }
  translate([0,0,th+0.1-h_lip_1-h_lip_2-h_lip_3])
    bin_lip(dx,dy);

  translate([0,0,h_feet_bin+0.19])
  rounded_rectangle(dx_inside,dy_inside,th,r_bin_inside);
}
