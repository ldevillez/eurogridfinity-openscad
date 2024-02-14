include <standard.scad>

module fillet_rectangle(length, width, height, fillet){
  l = length/2 - fillet;
  w = width/2 - fillet;
  union(){
    translate([0,0, fillet])
    rounded_rectangle(length,width,height,fillet);
    translate([0, 0, fillet])
      hull(){
      // Bottom
      translate([-l, -w, 0])
      sphere(fillet);
      translate([-l, w, 0])
      sphere(fillet);
      translate([ l, -w, 0])
      sphere(fillet);
      translate([ l, w, 0])
      sphere(fillet);
    }
  }
}

module fillet_rectangle_tabs(length, width, height, l_tab, fillet){
  l = length/2 - fillet;
  w = width/2 - fillet;
  h = height ;
  union(){
    translate([length_tab/2,0,fillet])
    fillet_rectangle(length-length_tab, width, height+0.1, fillet);
    translate([0, 0, fillet])
      hull(){
      translate([-l, -w, 0])
      sphere(fillet);
      translate([-l, w, 0])
      sphere(fillet);
      translate([ l, -w, 0])
      sphere(fillet);
      translate([ l, w, 0])
      sphere(fillet);

      // small top
      translate([l, w, h])
      sphere(fillet);
      translate([l, -w, h])
      sphere(fillet);

      translate([-l + length_tab,  w, h-offset_tab+fillet])
      sphere(fillet);
      translate([-l + length_tab, -w, h-offset_tab+fillet])
      sphere(fillet);

      translate([-l,  w, h - length_tab+fillet])
      sphere(fillet);
      translate([-l, -w, h - length_tab+fillet])
      sphere(fillet);
    }
  }
}

module rounded_rectangle(length, width, height, radius){
  linear_extrude(height)
    // Positive and then negative to round
    offset(radius)
    offset(-radius)
    square([length,width], center = true);
}

module rounded_square(length, height, radius){
  linear_extrude(height)
    // Positive and then negative to round
    offset(radius)
    offset(-radius)
    square([length,length], center = true);
}


module hole_shape(manufacturing=0,length=20,offset_laser=0){
  if(manufacturing == 0){
    union(){
      hull(){
      translate([0,0,h_base_1 + h_base_2 + h_base_3])
      rounded_square(length, 0.2, r_base);
      translate([0,0,h_base_1+h_base_2])
      rounded_square(length-2*h_base_3, h_base_3, r_base - h_base_3);
      }
      hull(){
      translate([0,0,h_base_1])
      rounded_square(length-2*h_base_3, h_base_2+0.1, r_base - h_base_3);
      rounded_square(length-2*h_base_3-2*h_base_1, h_base_1, r_base - h_base_3-h_base_1);
      }
      translate([0,0,-0.1])
      rounded_square(length-2*h_base_3-2*h_base_1, 0.2, r_base - h_base_3-h_base_1);
    }
  } else {
    translate([0,0,-0.1])
    rounded_square(length - 2*h_base_3 + offset_laser, 10, r_base-h_base_3);
  }
}

module unit_hole_shape(manufacturing=0,offset_laser=0){
  hole_shape(manufacturing,lbp_unit,offset_laser);
}

module unit_hole_magnet(){
    for (i = [-1:2:1])
      for (j = [-1:2:1])
        translate([i*13,j*13,0])
        cylinder(h=10,r=r_magnet);
}


module half_unit_hole_shape(manufacturing=0,offset_laser=0){
  hole_shape(manufacturing,lbp_half_unit, offset_laser);
}

module half_unit_hole_magnet(){
  translate([2.5,2.5,5])
  cylinder(h=10,r=r_magnet,center=true);
}

module grid(nx, ny, l) {
  translate([-nx*l/2 - l/2, -ny*l/2 - l/2, 0])
    for (i = [1:nx]){
      for (j = [1:ny]){
        translate([i*l,j*l,0])
        children();
      }
    }
}

module prep_for_laser(manufacturing = 0, prep=false, offsetx=0, offsety=0){
// Project if laser cut + asking for prep files
  if(manufacturing == 0 || prep == false){
    children();
  } else {
    translate([offsetx, offsety, 0]) projection() children();
  }
}



module bin_feet(length=lbi_unit){
  union(){
    hull(){
      rounded_square(length-2*h_bin_1-2*h_bin_3, h_bin_1,r_bin-h_bin_1/2-h_bin_3/2);
      translate([0,0,h_bin_1])
      rounded_square(length-2*h_bin_3, h_bin_2+0.1,r_bin-h_bin_3/2);
    }
    hull(){
      translate([0,0,h_bin_1+h_bin_2])
      rounded_square(length-2*h_bin_3, 0.1,r_bin-h_bin_3/2);
      translate([0,0,h_feet_bin])
      rounded_square(length, 0.1,r_bin);
    }
  }
}


module unit_bin_feet(){
  bin_feet(lbi_unit);
}

module half_unit_bin_feet(){
  bin_feet(lbi_half_unit);
}

module bin_lip(lx,ly){
  union(){
    hull(){
      rounded_rectangle(lx-h_lip_1-h_lip_3, ly-h_lip_1-h_lip_3, h_lip_1,r_bin-h_lip_1/2-h_lip_3/2);
      translate([0,0,h_lip_1])
      rounded_rectangle(lx-h_lip_3, ly-h_lip_3, h_lip_2+0.1,r_bin-h_lip_3/2);
    }
    hull(){
      translate([0,0,h_lip_1+h_lip_2])
      rounded_rectangle(lx-h_lip_3, ly-h_lip_3, 0.1,r_bin-h_lip_3/2);
      translate([0,0,h_lip_1+h_lip_2+h_lip_3])
      rounded_rectangle(lx,ly, 0.1,r_bin);
    }
  }
}

module tab_bin(l_tab, lenght){
  p = [
    [0,0],
    [-offset_tab,0],
    [-offset_tab,l_tab+offset_tab+0.1],
    [l_tab, l_tab + offset_tab+0.1],
    [l_tab, l_tab],
  ];
  linear_extrude(lenght,center=true)
  polygon(p);

}
