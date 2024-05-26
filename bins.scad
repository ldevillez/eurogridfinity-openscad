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

// Bottom type
bottom_type = 0; // [0: Flat, 1: Rounded bottom, 2:Empty feet]

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
dx_inside = dx - (h_lip_1 + h_lip_3);
dy_inside = dy - (h_lip_1 + h_lip_3);
th = gridz * lbi_h + lbi_lip;
// h inside the bin
h_inside = th-h_lip-h_feet_bin - t_bot_bin;

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

difference(){


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


    // Empty bin
    translate([0,0,h_feet_bin+ t_bot_bin])
    grid(compx, 1, dx_comp + t_comp)
    grid(1, compy, dy_comp + t_comp)
    // With a flat bottom
    if(bottom_type == 0 || bottom_type == 2){
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
  // Empty feet
    if(bottom_type == 2){
      translate([0, 0, t_comp])
        difference(){
          grid(gx,gy,l_bp)
          bin_feet(l_bi-t_comp);

          // Remove separators
          if(compy > 1){
              grid(1, compy - 1, dy_comp + t_comp)
              translate([-dx/2,-t_comp/2,-0.5])
              cube([dx, t_comp, h_feet_bin+1]);
          }
          if (compx > 1){
              grid(compx -1, 1, dx_comp + t_comp)
              translate([-t_comp/2,-dy/2,-0.5])
              cube([t_comp,dy, h_feet_bin+1]);
          }
        }
    }
  }
}

}
