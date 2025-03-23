include <BOSL2/std.scad>
//include <local/defaults.scad>

function mm(x = 1) = x;
function half(x = 0) = x / 2;
function twice(x = 0) = x * 2;
function through(x = 0) = x + 0.005;

$fn = $preview ? 36 : 192;

//projection() 
//zflip()
foot();


module foot() {
    foot_y  = mm(60);
    gap_y   = mm(100);
    rear_angle_y = mm(5);

    notch = [mm(2.5), 0];
    height = mm(21);
    outline_layers = 7;
    minor_offset = height / outline_layers;


    outline = [
        [0, 0]      + notch,
        [0, foot_y - notch.x] + notch, // maybe 62mm, hard to tell
        [0, foot_y],
        
        [0,       rear_angle_y + foot_y + gap_y + foot_y],
        [mm(18),  rear_angle_y + foot_y + gap_y + foot_y],
        [mm(20),  rear_angle_y + foot_y + gap_y],
        [mm(24),  rear_angle_y + foot_y],
        
        [mm(18), 0] + notch,
        [0,      0] + notch,
    ];

    outline_notch = offset(slice(outline, 4, 7), delta=-minor_offset);

    outline_minor = [
        outline[0],
        outline[1],
        outline[2],
        outline[3],
        [outline_notch[0].x, outline[4].y],
        outline_notch[1], 
        outline_notch[2],
        [outline_notch[3].x, outline[7].y],
        outline[8],
    ];

    difference() {

        // main body
        union() {
            for (layer = [0:(outline_layers - 1)], z = layer * minor_offset) {
                up(z)
                linear_extrude(height=minor_offset)
                polygon(layer % 2 ? outline_minor : outline, $fn=360);
            }
        }
        
        
        // rear angle
        //translate(outline[7] - [through(0), through(0)] )
        yrot(-90) 
        down(25)
        fwd(0.1)
        left(through(0))
        linear_extrude(30)
            polygon(right_triangle([
                outline[4].x + mm(0.5), 
                rear_angle_y + mm(0.5)
            ]))
        ;
        
        // cut off rear corner
        translate(outline[7])
        up(height)
        back(1)
        right(0.2)
        chamfer_edge_mask(minor_offset, chamfer=minor_offset, anchor=TOP);
        
        
        // finger grip cutout
        right(minor_offset)
        back(outline[6].y)
        up(height - twice(minor_offset))
        cuboid(
            [gap_y, gap_y, height], 
            //rounding=(minor_offset), 
            anchor=LEFT+TOP+FRONT
        );
        
        // chamfer around finger grip
        translate(outline[5] + [0, minor_offset])
        chamfer_edge_mask(
            l=height - minor_offset - 0.1, 
            chamfer=minor_offset, 
            anchor=RIGHT+BOTTOM, 
            spin=90
        );

        // chamfer around finger grip    
        translate(outline[6] + [-minor_offset, 0])
        chamfer_edge_mask(
            l=height - minor_offset - 0.1, 
            chamfer=minor_offset, 
            anchor=RIGHT+BOTTOM, 
            spin=180
        );
        
        
        // screw and bolt holes
        screw_holes() 
            down(through(0)) 
                cyl(d=mm(11), h=through(mm(11.5+2)), anchor=BOTTOM) 
                position(TOP) 
                cyl(d=mm(6.5), h=mm(7.5+0.1), anchor=BOTTOM) 
        ;
        bolt_holes() 
            down(through(0)) 
                cyl(d=mm(10.5), h=twice(height), anchor=BOTTOM)
        ;

        
    }


    module screw_holes() {
        holes(2) children();
    }

    module bolt_holes() {
        holes(1) children();
    }

    module holes(n) {
        dist_line_len = mm(52) - mm(10);
        foot_offset = [
            [8, mm(225 - 9) - half(dist_line_len)], // upper
            [9, mm(16)    + half(dist_line_len)] + notch, // lower
        ];
        
        for (offset = foot_offset) {
            echo(offset);
            translate(offset) 
                ycopies(l=dist_line_len, n=n) 
                    children();
        }
    }
}