const std = @import("std");

const Next = struct {
    left: []const u8,
    right: []const u8,
};

pub fn is_equal(a: []const u8, b: []const u8) bool {
    for (0..3) |i| {
        if (a[i] != b[i]) return false;
    }
    return true;
}

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    var hash_map = std.StringHashMap(Next).init(allocator);
    var starting_with_a = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.split(u8, read_buf, "\n\n");
    const key = it.next().?;
    const key_size = key.len;

    const map = it.next().?;
    var nexts = std.mem.split(u8, map, "\n");
    while (nexts.next()) |next| {
        //std.debug.print("{s}\n", .{next});
        var it_2 = std.mem.split(u8, next, " = ");
        const start = it_2.next().?;
        const next_steps = it_2.next().?;
        var it_3 = std.mem.tokenizeAny(u8, next_steps, "(), ");
        const left = it_3.next().?;
        const right = it_3.next().?;
        try hash_map.put(start, Next{ .left = left, .right = right });
        if (start[2] == 'A') try starting_with_a.append(start);
    }
    var lcm: usize = 1;
    for (starting_with_a.items) |start| {
        var step_count: usize = 0;
        var current_pos: []const u8 = start;
        while (current_pos[2] != 'Z') : (step_count += 1) {
            const next_step = hash_map.get(current_pos).?;
            if (key[step_count % key_size] == 'L') {
                current_pos = next_step.left;
            } else {
                current_pos = next_step.right;
            }
        }
        const gcd = std.math.gcd(lcm, step_count);
        lcm = lcm * step_count / gcd;
    }
    std.debug.print("{}\n", .{lcm});
}

// const std = @import("std");

// pub fn ending_with(a: []const u8, char: u8) bool {
//     return a[a.len - 1] == char;
// }

// pub fn is_equal(a: []const u8, b: []const u8) bool {
//     for (0..3) |i| {
//         if (a[i] != b[i]) return false;
//     }
//     return true;
// }

// pub fn main() !void {
//     const fileName = "second.txt";
//     const file = try std.fs.cwd().openFile(fileName, .{});
//     var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
//     defer arena.deinit();
//     const allocator = arena.allocator();
//     const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
//     defer allocator.free(read_buf);
//     defer file.close();
//     var string_to_id = std.StringHashMap(usize).init(allocator);
//     var z_ending = std.ArrayList(usize).init(allocator);

//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const alloc = gpa.allocator();
//     var running = std.ArrayList(usize).init(alloc);
//     var next_running = std.ArrayList(usize).init(alloc);
//     defer next_running.deinit();

//     var it = std.mem.split(u8, read_buf, "\n\n");
//     const key = it.next().?;
//     const key_size = key.len;

//     const map = it.next().?;
//     var names_to_usize_it = std.mem.split(u8, map, "\n");
//     var id: usize = 0;
//     while (names_to_usize_it.next()) |line| : (id += 1) {
//         var it_2 = std.mem.split(u8, line, " = ");
//         const name = it_2.next().?;
//         try string_to_id.put(name, id);
//         if (ending_with(name, 'Z')) try z_ending.append(id);
//         if (ending_with(name, 'A')) {
//             try running.append(id);
//             std.debug.print("{s}\n", .{name});
//         }
//     }
//     var lookup = try alloc.alloc(bool, id + 1);
//     for (z_ending.items) |item| {
//         lookup[item] = true;
//     }
//     var left: []usize = try alloc.alloc(usize, id + 1);
//     var right: []usize = try alloc.alloc(usize, id + 1);
//     var nexts = std.mem.split(u8, map, "\n");
//     while (nexts.next()) |next| {
//         var it_2 = std.mem.split(u8, next, " = ");
//         const start = string_to_id.get(it_2.next().?).?;
//         const next_steps = it_2.next().?;
//         var it_3 = std.mem.tokenizeAny(u8, next_steps, "(), ");
//         left[start] = string_to_id.get(it_3.next().?).?;
//         right[start] = string_to_id.get(it_3.next().?).?;
//     }
//     var step_count: usize = 0;
//     std.debug.print("{}\n", .{running.items.len});
//     var ending_with_z: usize = 0;
//     while (ending_with_z != running.items.len) : (step_count += 1) {
//         ending_with_z = 0;
//         for (running.items) |item| {
//             var current_pos: usize = undefined;
//             if (key[step_count % key_size] == 'L') {
//                 current_pos = left[item];
//             } else {
//                 current_pos = right[item];
//             }
//             try next_running.append(current_pos);
//             if (lookup[current_pos]) ending_with_z += 1;
//         }
//         running.deinit();
//         running = next_running;
//         next_running = std.ArrayList(usize).init(alloc);
//     }

//     std.debug.print("{}\n", .{step_count});
// }
