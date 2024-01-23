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
// Remove the fillet
flat_bottom = true;
// Tabs
tabs = true;
// Tab length
length_tab=9;


/* [Half-grid] */
// Use half grid instead of regular grid
half_grid = true;

// ===== IMPLEMENTATION ===== //

// total x
dx = gridx * lbp_unit - 0.5;
// total y
dy = gridy * lbp_unit - 0.5;
dx_inside = dx - 2 * (h_lip_1 + h_lip_3);
dy_inside = dy - 2 * (h_lip_1 + h_lip_3);
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
    translate([0,0,th-h_lip])
      bin_lip(dx,dy);

    // h inside the bin
    h_inside = th-h_lip-h_feet_bin - t_bot_bin;

    // Empty bin
    translate([0,0,h_feet_bin+ t_bot_bin])
    grid(compx, 1, dx_comp + t_comp)
    grid(1, compy, dy_comp + t_comp)
    // With a flat bottom
    if(flat_bottom){
      difference(){
        rounded_rectangle(dx_comp,dy_comp,h_inside + 1,r_bin_inside);
        // Adding tabs
        if(tabs){
          translate([-dx_comp/2,0,h_inside-length_tab-offset_tab])
          rotate([90,0,0])
          tab_bin(length_tab, dy_comp);
        }

      }
      // Or a round bottom
    } else {
      if(tabs){
        // TODO: better tabs (do some geometry)
        fillet_rectangle_tabs(dx_comp,dy_comp,h_inside - 2*r_bin_inside, length_tab,r_bin_inside);
      } else {
        fillet_rectangle(dx_comp,dy_comp,h_inside + 1,r_bin_inside);
      }
    }
  }
}
