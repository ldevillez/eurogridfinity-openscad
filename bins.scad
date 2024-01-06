include <utility.scad>
include <standard.scad>


// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 2; // .5
// number of bases along y-axis
gridy = 2; // .5
// number of bases along z-axis
gridz = 5;

/* [Feature] */
// Number of compartiments along x-axis
compx = 2;
// Number of compartiments along y-axis
compy = 2;

/* [Half-grid] */
// Use half grid instead of regular grid
half_grid = true;

// ===== IMPLEMENTATION ===== //

dx = gridx * lbp_unit - 0.5;
dy = gridy * lbp_unit - 0.5;
dx_inside = dx - h_lip_1 - h_lip_3;
dy_inside = dy - h_lip_1 - h_lip_3;
th = gridz * lbi_h + lbi_lip;

// Dividers
dx_comp = (dx_inside - (compx - 1) * t_comp) / compx;
dy_comp = (dy_inside - (compy - 1) * t_comp) / compy;

// is half_grid
hgrid = half_grid || (gridx * 10) % 10 > 0.1 || (gridy * 10) % 10 > 0.1;

// x number of feet
gx = hgrid ? gridx * 2 : gridx;
// y number of feet
gy = hgrid ? gridy * 2 : gridy;
// length of a baseplate unit
l_bp = hgrid ? lbp_half_unit : lbp_unit;
// length of a bin unit
// Need an offset of 0.5 to avoid overshooting of the bins. Grids of the bins and baseplate is not the same
l_bi = hgrid ? lbi_half_unit - 0.5 : lbi_unit;


union(){
  difference(){
    union(){
      // Feets
      translate([0, 0, 0])
      grid(gx,gy,l_bp)
        bin_feet(l_bi);

      // Mainbody
      translate([0,0,h_feet_bin])
      rounded_rectangle(dx,dy,th-h_feet_bin,r_bin);
    }
    // Remove material to make lip
    translate([0,0,th-h_lip_1-h_lip_2-h_lip_3])
      bin_lip(dx,dy);

    // Empty bin
    translate([0,0,h_feet_bin+0.19])
    grid(compx, 1, dx_comp + t_comp)
    grid(1, compy, dy_comp + t_comp)
    rounded_rectangle(dx_comp,dy_comp,th,r_bin_inside);
  }
  /*// X separator*/
  /*if(compx > 1){*/
    /*for (i = [1:compx-1]){*/
      /*translate([-t_comp/2 -dx/2 + i * dx /compx, -dy/2,h_feet_bin])*/
      /*cube([t_comp, dy, th - h_feet_bin - h_lip]);*/
    /*}*/
  /*}*/

  /*// Y separator*/
  /*if(compy > 1){*/
    /*for (i = [1:compy-1]){*/
      /*translate([-dx/2, -t_comp/2 - dy/2 + i * dy / compy,h_feet_bin])*/
      /*cube([dx,t_comp,th - h_feet_bin - h_lip]);*/
    /*}*/
  /*}*/
}

    /*translate([0, 0,h_feet_bin+0.19])*/
    /*grid(compx, 1, dx_comp + t_comp)*/
    /*grid(1, compy, dy_comp + t_comp)*/
    /*rounded_rectangle(dx_comp,dy_comp,th,r_bin_inside);*/
