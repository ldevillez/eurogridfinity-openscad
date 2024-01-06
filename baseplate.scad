include <utility.scad>
include <standard.scad>


// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 1;
// number of bases along y-axis
gridy = 1;

// How to make the base plate
manufacturing = 0; // [0: 3D_print, 1:Lasercut]

// How to make the base plate
prepare_for_laser = false;

/* [Fit to Drawer] */
// minimum length of baseplate along x (leave zero to ignore, will automatically fill area if gridx is zero)
dix = 0;
// minimum length of baseplate along y (leave zero to ignore, will automatically fill area if gridy is zero)
diy = 0;

// where to align extra space along x
fitx = 0; // [-1:0.1:1]
// where to align extra space along y
fity = 0; // [-1:0.1:1]

/* [Half-grid] */
// Use half grid instead of regular grid
half_grid = true;
// Remove half grid row on x axis
disable_extra_half_x = false;
// Remove half grid row on x axis
disable_extra_half_y = false;

/* [Style] */
style_baseplate = 0; // [0: Thin, 1: Solid, 2:Magnet]



// ===== IMPLEMENTATION ===== //

// Get x, y in function of parameters
gx = gridx <= 0 ? floor(dix/lbp_unit) : gridx;
gy = gridy <= 0 ? floor(diy/lbp_unit) : gridy;

// Check values
assert(gx > 0 || dix > lbp_half_unit, "Must have positive x grid amount! (gridx > 0 or dix > lbp_half_unit)");
assert(gy > 0 || diy > lbp_half_unit, "Must have positive y grid amount! (gridy > 0 or diy > lbp_half_unit)");

// Get length
dx = max(gx*lbp_unit, dix);
dy = max(gy*lbp_unit, diy);

// Get offset
offsetx = dix < dx ? 0 : (gx*lbp_unit-dix)/2*fitx*-1;
offsety = diy < dy ? 0 : (gy*lbp_unit-diy)/2*fity*-1;

trans_x_unit = -(gx+0.5)*lbp_half_unit + offsetx;
trans_y_unit = -(gy+0.5)*lbp_half_unit + offsety;

// Is an extra row top or bottom
half_row_x = lbp_half_unit <= abs(offsetx*2) && !disable_extra_half_x;
half_row_y = lbp_half_unit <= abs(offsety*2) && !disable_extra_half_y;

// Get thickness
th = manufacturing == 0 ? t_3d : t_laser;
th_off = manufacturing == 1 ? 0 : style_baseplate == 0 ? 0 : bp_h_bot;

// main base plate rounded_rectangle with holes
prep_for_laser(manufacturing, prepare_for_laser) difference(){
  union(){
    difference(){

      // Base plate
      translate([0,0,-th_off])
      rounded_rectangle(dx,dy,th+th_off,r_base);

      //_Main grid
      if(half_grid){
        translate([offsetx, offsety, -0.1])
          grid(gx*2,gy*2,lbp_half_unit)
          half_unit_hole_shape(manufacturing);
      } else {
        translate([offsetx,  offsety,0])
          grid(gx,gy,lbp_unit)
          unit_hole_shape(manufacturing);
      }

      // Additional rows
      if(half_row_x){
      translate([offsetx- sign(fitx) * (gx+0.5) * lbp_half_unit, offsety, -0.1])
          grid(1,gy*2,lbp_half_unit)
          half_unit_hole_shape(manufacturing);
      }
      if(half_row_y){
      translate([offsetx, -sign(fity) * (gy+0.5) * lbp_half_unit + offsety, -0.1])
          grid(gy*2,1,lbp_half_unit)
          half_unit_hole_shape(manufacturing);
      }

      // Additional corner
      if(half_row_x && half_row_y){
      translate([-sign(fitx) * (gx+0.5)*lbp_half_unit + offsetx, -sign(fity) * (gy+0.5)*lbp_half_unit + offsety ,-0.1])
          half_unit_hole_shape(manufacturing);

      }

    }

    // Add back thickness for solid / magnet. (needed to avoid the small gap created by the holes)
    if(manufacturing == 0 && style_baseplate != 0){
      translate([0,0,-th_off])
      rounded_rectangle(dx,dy,th_off,r_base);

    }
  }

  // Holes in base
  if(manufacturing == 0 && style_baseplate != 0){
    // Magnet hole
    if(style_baseplate == 2){
      translate([offsetx, offsety,-h_magnet])
        grid(gx,gy,lbp_unit)
        unit_hole_magnet();

      if(half_row_x){
      translate([offsetx- sign(fitx) * (gx+0.5) * lbp_half_unit, offsety, -h_magnet])
          grid(1,gy*2,lbp_half_unit)
          half_unit_hole_magnet();
      }
      if(half_row_y){
      translate([offsetx, -sign(fity) * (gy+0.5) * lbp_half_unit + offsety, -h_magnet])
          grid(gy*2,1,lbp_half_unit)
          half_unit_hole_magnet();
      }
      if(half_row_x && half_row_y){
      translate([-sign(fitx) * (gx+0.5)*lbp_half_unit + offsetx, -sign(fity) * (gy+0.5)*lbp_half_unit + offsety ,-h_magnet])
          half_unit_hole_magnet();
      }
    }

  }
}


// Bottom plate for laser cutting
if(style_baseplate != 0 && manufacturing == 1){
  prep_for_laser(manufacturing, prepare_for_laser, dx+2,0)
  translate([0,0,-t_laser])
    // To highlight multiple body
    color("tomato")
    difference(){
      // Same sheet as before
      rounded_rectangle(dx,dy,th,r_base);

      if(style_baseplate == 2){
        // Regular magnet holes
        translate([-(gx+1)*lbp_half_unit + offsetx, -(gy+1)*lbp_half_unit + offsety,-0.1])
          grid(gx,gy,lbp_unit)
          unit_hole_magnet();

        // Additional row holes
        if(half_row_x){
        translate([(gx-0.5)*lbp_half_unit + offsetx ,trans_y_unit, -0.1])
            grid(1,gy*2,lbp_half_unit)
            half_unit_hole_magnet();
        }
        // Additional row holes
        if(half_row_y){
        translate([trans_x_unit, (gy-0.5)*lbp_half_unit + offsety ,-0.1])
            grid(gy*2,1,lbp_half_unit)
            half_unit_hole_magnet();
        }

        // Additional corner hole
        if(half_row_x && half_row_y){
        translate([(gx+0.5)*lbp_half_unit + offsetx, (gy+0.5)*lbp_half_unit + offsety ,-0.1])
            half_unit_hole_magnet();
        }


      }
    }
}
