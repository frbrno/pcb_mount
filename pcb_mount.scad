include <BOSL2/std.scad>

// space between plug and jack for example
clearence = 0.4;

// circuit board dimensions
pcb_x = 50.8 + clearence; // min 50
pcb_y = 70 + clearence;
pcb_z = 2;

// (red color) pcb lies on top of it
inner_support_width = 1.2;
inner_support_height = 1.4;

// (blue color) width around pcb
outer_width = 2; // min:2
outer_height = inner_support_height + pcb_z + 2;

// (green) for placing wires
wire_addon_enable = true;
wire_addon_pcb_x = pcb_x; // do not change
wire_addon_pcb_y = 16;
wire_addon_pcb_z = pcb_z; // do not change

// (yellow) connector for pcb_mount_cover and pcb_mount_rail
connector_enable = true;
connector_x = 10; // do not change
connector_y = 5;  // do not change
connector_z = 2.6;

// total dimensions of pcb_mount_cover
total_x = pcb_x + 2 * outer_width; // do not change
total_y = wire_addon_enable ? (pcb_y + 2 * outer_width) + wire_addon_pcb_y + outer_width
                            : pcb_y + 2 * outer_width; // do not change
total_z = outer_height;                                // do not change

james_bond = 0.007; // do not change, magic number for openscad things

// pcb_mount_rail
rail_z_support = 1.4;                              // (#red) below the pcb cover connectors
rail_x = total_x + 2 * clearence - james_bond;     // do not change width of rail for each part of pcb mount cover
rail_y = 2 * connector_y + 1.2;                    // do not change
rail_z = rail_z_support + clearence + connector_z; // do not change

// few examples:
info();
// pcb_mount_cover();
// pcb_mount_rail(pcb_count=1, conn_left = true, conn_right = true);
// pcb_mount_rail(pcb_count=2, conn_left = false, conn_right = true);
// pcb_mount_rail(pcb_count=3, conn_left = false, conn_right = false);
// pcb_mount_rail(pcb_count=4, conn_left = false, conn_right = false);

// pcb_mount_rail(pcb_count = 2, conn_left = false, conn_right = true);

module info()
{
    pcb_mount_cover();
    translate([ 0, total_y / 2 + 14, 0 ]) pcb_mount_rail(pcb_count = 1, conn_left = true, conn_right = true);
    translate([ 0, total_y / 2 + 30, 0 ]) pcb_mount_rail(pcb_count = 2, conn_left = false, conn_right = true);
    translate([ 0, total_y / 2 + 46, 0 ]) pcb_mount_rail(pcb_count = 3, conn_left = true, conn_right = false);
    translate([ 0, total_y / 2 + 62, 0 ]) pcb_mount_rail_lock(pcb_count = 1, height = 1.4);
    translate([ 0, total_y / 2 + 78, 0 ]) pcb_mount_rail_lock(pcb_count = 3, height = 1.4);
}

module pcb_mount_cover()
{
    pos_y_correction_wire_addon = wire_addon_enable ? (wire_addon_pcb_y + outer_width) / 2 : 0;
    ymove(pos_y_correction_wire_addon) base();

    if (wire_addon_enable)
    {
        color("green") ymove((pcb_y + 2 * outer_width) / -2) wire_addon();
    }

    if (connector_enable)
    {
        ymove((total_y) / 2 + (connector_y / 2))
        {
            xmove((pcb_x + 2 * outer_width) / -4) connector();
            xmove((pcb_x + 2 * outer_width) / 4) connector();
        }

        ymove((total_y) / -2 - (connector_y / 2)) zrot(180)
        {
            connector();
        }
    }
}

module pcb_mount_rail(pcb_count = 2, conn_left = true, conn_right = true)
{

    for (num = [0:1:pcb_count - 1])
    {
        xmove(num * rail_x)
        {
            difference()
            {

                if (conn_left && num == 0)
                {
                    difference()
                    {
                        cube_anchor([ 0, 0, 1 ], rail_x, rail_y, rail_z);
                        left(rail_x / 2) cube_anchor([ 1, 0, 0 ], clearence, 22, 22);
                    }
                }
                else
                {
                    cube_anchor([ 0, 0, 1 ], rail_x, rail_y, rail_z);
                }
                up(rail_z_support)
                {
                    ymove(connector_y - 1) ymove(total_y / 2) color("red") linear_extrude(height = 2 * total_z)
                        offset(delta = clearence) projection(cut = false) pcb_mount_cover();
                    ymove(-connector_y + 1) ymove(total_y / -2) color("red") linear_extrude(height = 2 * total_z)
                        offset(delta = clearence) projection(cut = false) pcb_mount_cover();
                }
                pcb_mount_rail_screw_holes(pcb_count, num, conn_left, conn_right);

                if (conn_left && num == 0)
                {
                    left(rail_x / 2) right(5 / 2) zrot(-90) down(2) connector(true, 4, 5, 2 * rail_z, 1);
                }
            }
            if (conn_right && num == pcb_count - 1)
            {
                right(rail_x / 2) right(5 / 2) zrot(-90) connector(false, 4, 5, rail_z, 1);
            }
        }
    }
}

module pcb_mount_rail_lock(pcb_count = 1, height = 1.4)
{
    for (num = [0:1:pcb_count - 1])
    {
        xmove(num * rail_x) difference()
        {
            cube_anchor([ 0, 0, 1 ], rail_x, 2 * connector_y - 2 * clearence, height);
            pcb_mount_rail_screw_holes(pcb_count, num, false, false);
        }
    }
}

module pcb_mount_rail_screw_holes(pcb_count, num, conn_left, conn_right)
{
    if (!conn_left && num == 0)
    {
        up(4) up(rail_z) right(8 / 2) left(rail_x / 2) my_screw();
    }

    if (num == pcb_count - 1)
    {
        up(4) up(rail_z) left(8 / 2) right(rail_x / 2) my_screw();
    }

    if (num > 0 && num <= pcb_count - 1)
    {
        up(4) up(rail_z) left(rail_x / 2) my_screw();
    }

    if (num >= 0 && num < pcb_count - 1)
    {
        up(4) up(rail_z) right(rail_x / 2) my_screw();
    }
}

module connector(hole = false, x = connector_x, y = connector_y, z = connector_z, hook = 2)
{
    module part()
    {
        difference()
        {
            cube_anchor([ 0, 0, 1 ], x, y, z);
            ymove(-2) left(x / 2 - hook) cube_anchor([ -1, 0, 0 ], 22, y, 22);
            ymove(-2) right(x / 2 - hook) cube_anchor([ 1, 0, 0 ], 22, y, 22);
        }
    }
    if (hole == false)
    {
        part();
    }
    else
    {
        linear_extrude(height = z) offset(delta = clearence) projection() part();
    }
}

module base()
{
    // inner support
    color("red") difference()
    {
        cube_anchor([ 0, 0, 1 ], pcb_x, pcb_y, inner_support_height);
        cube([ pcb_x - 2 * inner_support_width, pcb_y - 2 * inner_support_width, 22 ], center = true);
    }

    // outer
    color("blue") difference()
    {
        cube_anchor([ 0, 0, 1 ], pcb_x + 2 * outer_width, pcb_y + 2 * outer_width, outer_height);
        cube([ pcb_x, pcb_y, 22 ], center = true);
        up(inner_support_height + pcb_z) cube_anchor([ 0, 0, 1 ], pcb_x - 2 * inner_support_width, 2 * pcb_y, 22);
        up(inner_support_height + pcb_z) cube_anchor([ 0, 0, 1 ], 2 * pcb_x, pcb_y - 2 * inner_support_width, 22);
    }
}

module wire_addon()
{
    difference()
    {
        cube_anchor([ 0, 0, 1 ], wire_addon_pcb_x + 2 * outer_width, wire_addon_pcb_y + outer_width, outer_height);
        ymove(outer_width / 2)
        {
            cube_anchor([ 0, 0, 0 ], wire_addon_pcb_x - 2 * inner_support_width, wire_addon_pcb_y, 22);
            up(inner_support_height) cube_anchor([ 0, 0, 1 ], wire_addon_pcb_x, wire_addon_pcb_y, 22);
            up(inner_support_height + wire_addon_pcb_z)
            {
                cube_anchor([ 0, 0, 1 ], wire_addon_pcb_x - 2 * inner_support_width, 2 * wire_addon_pcb_y, 22);
                cube_anchor([ 0, 0, 1 ], 2 * wire_addon_pcb_x, wire_addon_pcb_y - 2 * inner_support_width, 22);
            }
        }
    }
}

module my_screw(h = 12, d = 4, head_d = 8, head_h = 3)
{
    down(1) cylinder(h = 2, d = head_d, center = true, $fn = 32);
    down(head_h / 2 + 2) cylinder(h = head_h, d1 = d, d2 = head_d, center = true, $fn = 32);
    down(h / 2 + 2 + 1) cylinder(h = h, d = d, center = true, $fn = 32);
}

module cube_anchor(anchor = [ 0, 0, 0 ], x, y, z)
{
    xmove(anchor[0] * (x / 2)) ymove(anchor[1] * (y / 2)) zmove(anchor[2] * (z / 2)) cube([ x, y, z ], center = true);
}