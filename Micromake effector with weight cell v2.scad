separation = 42;   // Distance between ball joint mounting faces.
delta_radius = 34; // Distance between center and the line on which ball joints
                   // are located.
                   
e3d_radius = 26/2; // Radius of E3D v5 cooling part

echo("<b>Delta radius value for EEPROM is: </b>", str(sqrt(pow(separation / 2, 2) + pow(delta_radius, 2))));

height = 10;       // Height of the plate

m3_radius = 1.6;
m3_nut_radius = 3.5;

  #cube([0.05, 0.05, height * 6], center = false); // debug, for measurements on generated STL file

effector();



//////////////////////////////////////////////////////////////

// Combines 3 equal sectors of the effector plate into one part:
module effector() {
  union() {
    difference() {
      for (a = [ 0, 120, 240 ]) {
        rotate([ 0, 0, a ]) { one_third_of_effector(); }
      }
      // Central hole for e3d v5 effector (cone-shaped to improve cooling):
      cylinder(r1 = e3d_radius, r2 = e3d_radius + 5, h = height + 2,
               center = true, $fn = 128);
    }
    weight_cell_bottom_bracket();
  }
}

// Effector plate is made out of 3 identical sectors:
module one_third_of_effector() {
  // Longer beam
  rotate([ 0, 0, 30 ]) {

    intersection() {
      translate([ 18, 0, 0 ]) {
        rotate([ 0, 90, 90 ]) {
          // Cylinder makes the edges rounded
          cylinder(r = 10, h = separation, center = true, $fn = 96);
        }
      }

      translate([ delta_radius - 14, 0, 0 ]) {
        difference() {
          cube([ delta_radius / 2, delta_radius * 1.1, height ], center = true);
          leds();
        }
      }
    }
  }

  // Shorter beam
  rotate([ 0, 0, 90 ]) {
    intersection() {
      translate([ 20, 0, 0 ]) {
        rotate([ 0, 90, 90 ]) {
          // Cylinder makes the edges rounded
          cylinder(r = 10, h = separation, center = true, $fn = 96);
        }
      }
      translate([ 20, 0, 0 ]) {
        cube([ 20, delta_radius * 0.5, height ], center = true);
      }
    }
  }

  // Ball joint mounts
  cone_r1 = 3.0;
  cone_r2 = 14;
  for (s = [ -1, 1 ]) {
    scale([ s, 1, 1 ]) {
      translate([ 0, delta_radius, 0 ]) {
        difference() {
          intersection() {
            // Rectangle that bounds the mount:
            cube([ separation, 40, height ], center = true);
            translate([ 0, -4, 0 ]) {
              rotate([ 0, 90, 0 ]) {
                // Cylinder makes the edges rounded
                cylinder(r = 10, h = separation, center = true, $fn = 96);
              }
            }
            translate([ separation / 2 - 7, 0, 0 ]) {
              rotate([ 0, 90, 0 ]) {
                // Cone-shaped noses of the mounts
                cylinder(r1 = cone_r2, r2 = cone_r1, h = 14, center = true,
                         $fn = 48);
              }
            }
          }
          // Cut-out for M3 bolts
          rotate([ 0, 90, 0 ]) {
            cylinder(r = m3_radius, h = separation + 1, center = true,
                     $fn = 48);
          }
          // Cut-out for M3 washers
          rotate([ 90, 0, 90 ]) {
            cylinder(r = m3_nut_radius, h = separation - 24, center = true,
                     $fn = 6);
          }
        }
      }
    }
  }
}

// 2 holes for LED lights on each long beam:
module leds() {
  LED_diameter = 5; // Typical LED is 5mm
  for (l = [ -1.3 * LED_diameter, 1.3 * LED_diameter ]) {
    translate([ 0, l, 0 ]) {
      rotate([ 0, 25, 0 ]) { // 25-degree angle towards nozzle
        translate([ 0, 0, -3 ]) {
          translate([ 0, 0, 0 ]) {
            cylinder(r = (LED_diameter / 2) * 1.4, h = height + 3,
                     center = false, $fn = 42);
          }
          cylinder(r = LED_diameter / 2, h = height * 2, center = true,
                   $fn = 42);
        }
      }
    }
  }
}

module weight_cell_bottom_bracket() {

  bottom_bracket_height = height + 2;
  bottom_bracket_width = 20;
  bottom_bracket_depth = 12;

  slit_depth = 6.5; // Dimensions of the pocket to which weight cell goes into
  slit_width = 13;

  distance_btw_mnt_holes = 7;
  distance_frmtop_mnt_holes = 2.5;

  translate([
    -1 * (bottom_bracket_width / 2),
    delta_radius - (bottom_bracket_depth + 5.5),
    -1 * (height / 2)
  ]) {

    difference() {
      // Walls that hold the bottom of weight cell:
      difference() {
        cube([
          bottom_bracket_width,
          bottom_bracket_depth,
          2 * bottom_bracket_height
        ]);
        translate([
          (bottom_bracket_width - slit_width) / 2,
          (bottom_bracket_depth - slit_depth) / 2,
          bottom_bracket_height
        ]) {
          cube([ slit_width, slit_depth, bottom_bracket_height+1 ]);
        }
      }
      // Mounting holes:
      translate([
        bottom_bracket_width / 2,
        bottom_bracket_depth / 2,
        height + bottom_bracket_height - distance_frmtop_mnt_holes
      ]) {
        rotate([ 90, 0, 0 ]) {
          // There are 2 identical holes:
          for (m = [
                 distance_btw_mnt_holes / -2,
                 distance_btw_mnt_holes / 2
               ]) {
            translate([ m, 0, 0 ]) {
              cylinder(r = m3_radius, h = bottom_bracket_depth, $fn = 48, center = true);
              translate([ 0, 0, bottom_bracket_depth / 2 ]) {
                cylinder(r = m3_nut_radius, h = 3, $fn = 48, center = true);
              }
              translate([ 0, 0, -1 * bottom_bracket_depth / 2 ]) {
                cylinder(r = m3_nut_radius, h = 3, $fn = 6, center = true);
              }
            }
          }
        }
      }
    }
  }
}

