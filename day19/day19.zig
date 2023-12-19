const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const FPtr = struct {
    cmp: fn (Val) bool,
    res: []const u8,
};

const Workflow = struct {
    name: []const u8,
    functions: std.ArrayList(FPtr),
};

const Val = struct {
    a: i64,
    m: i64,
    s: i64,
    x: i64,
};

fn get_next(v: Val, w: Workflow, map: std.StringHashMap(Workflow)) Workflow {
    for (w.functions.items) |f| {
        if (f.cmp(v)) {
            return map.get(f.res).?;
        }
    }
    unreachable;
}

fn main() !void {
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var it = std.mem.split(u8, read_buf, "\n\n");
    const workflows = it.next().?;
    _ = workflows;
    const values = it.next();
    _ = values;
}
