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

fn has_conditions(s: []const u8) bool {
    for (s) |i| {
        if (i == ':') return true;
    }

    return false;
}

fn to_fn(va: u8, val: i64, res: []const u8, cmp: u8) fn (Val) bool {
    var mul: i64 = 1;
    if (cmp == '<') mul = -1;
    if (va == 'x') {
        const f = fn (v: Val) bool{v.x > val};
        return f;
    } else if (va == 'm') {} else if (va == 'a') {} else {}
    return true;
}

fn string_to_workflow(s: []const u8) !Workflow {
    var it = std.mem.tokenizeAny(u8, s, "{}");
    const name = it.next().?;
    const conditions = it.next().?;
    var fns = std.ArrayList(fn (Val) bool).init(allocator);
    var it_2 = std.mem.tokenizeAny(u8, conditions, ",");
    while (it_2.next()) |c| {
        if (has_conditions(c)) {
            const cmp = c[1];
            _ = cmp;
            var it_3 = std.mem.tokenizeAny(u8, c, ":<>");
            var va = it_3.next().?[0];
            _ = va;
            var val = try std.fmt.parseInt(i64, it_3.next().?, 10);
            _ = val;
            var res = it_3.next().?;
            _ = res;
            // const f =
        } else {
            const f = fn (v: Val) bool{return true};
            try fns.append(FPtr{
                .cmp = f,
                .res = c,
            });
        }
    }

    return Workflow{
        .name = name,
        .functions = fns,
    };
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
