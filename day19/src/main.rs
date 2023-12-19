use std::*;

#[derive(Clone, Copy)]
struct Val {
    x: i64,
    m: i64,
    a: i64,
    s: i64,
}

#[derive(Clone)]
struct FPtr {
    res: String,
    cmp: fn(Val) -> bool,
}
#[derive(Clone)]
struct Workflow {
    name: String,
    functions: Vec<FPtr>,
}

fn get_next(v: Val, w: Workflow, map: collections::HashMap<String, Workflow>) -> Workflow {
    for f in w.functions {
        if (f.cmp)(v) == true {
            return map.get(&f.res).unwrap().clone();
        }
    }
    return Workflow {
        name: "asdf".to_owned(),
        functions: vec![],
    };
}

fn string_to_workflow(s: String) -> Workflow {
    let mut fns: Vec<FPtr> = vec![];
    let split: Vec<&str> = s.split(|c: char| c == '}' || c == '{').collect(); //name, conds
    let conds: Vec<&str> = split[1].split(",").collect();
    for c in conds {
        if c.contains(":") {
            let cmp: char = c.as_bytes()[1] as char;
            let split2: Vec<&str> = s.split(|c: char| c == ':' || c == '>' || c == '<').collect();
            let val = split2[1].parse::<i64>().unwrap();
            if cmp == '<' {
                if split2[0].as_bytes()[0] as char == 'x' {
                    let f = |v: Val| -> bool {
                        return v.x < val;
                    };
                    fns.push(FPtr {
                        cmp: f,
                        res: split2[2].to_string(),
                    });
                }
            }
        } else {
            let f = |_v: Val| -> bool {return true};
            fns.push(FPtr {
                res: c.to_string(),
                cmp: f,
            });
        }
    }
    return Workflow {
        name: "asdf".to_owned(),
        functions: vec![],
    };
}

fn main() {
    let content = fs::read_to_string("test.txt").expect("no file found");
    println!("{content}");
}
