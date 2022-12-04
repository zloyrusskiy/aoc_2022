extern crate mylib;

fn calc_elves_total_calories(input: Vec<String>) -> Vec<u64> {
    let mut chunk: Vec<u64> = Vec::new();
    let mut sums: Vec<u64> = Vec::new();
    for line in input {
        if line.is_empty() {
            sums.push(chunk.iter().sum::<u64>());
            chunk.clear();
        } else {
            chunk.push(line.parse::<u64>().unwrap());
        }
    }
    sums.push(chunk.iter().sum::<u64>());

    sums
}

fn part1(input: Vec<String>) -> u64 {
    let sums = calc_elves_total_calories(input);

    *sums.iter().max().unwrap()
}

fn part2(input: Vec<String>) -> u64 {
    let mut sums = calc_elves_total_calories(input);
    sums.sort_by(|a, b| b.cmp(a));

    sums.iter().take(3).sum::<u64>()
}

fn main() {
    let input = mylib::get_lines_from_stdin();

    println!("{:?}", part1(input.clone()));
    println!("{:?}", part2(input.clone()));
}
