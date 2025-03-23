include <BOSL2/std.scad>
include <local/defaults.scad>

// Sampler
/*
for (h = [mm(2):mm(2):mm(6)]) {
    back((h - 2) * mm(5))
    yrot(90) spacebar_bumper(height=h);
}
*/
spacebar_bumper(height=mm(4));


module spacebar_bumper(height=mm(4)) {
    finger = [mm(2), mm(5.2), mm(2.1)];
    part = finger + [0, mm(2), height];
    up(part.z) back(part.x) zflip() 
    difference() {
        cube(part);
        translate(half(part))
        cube([through(part.x), finger.y, finger.z], center=true); 
    }
}