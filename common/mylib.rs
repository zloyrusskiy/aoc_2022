use std::io;

pub fn get_lines_from_stdin() -> Vec<String> {
  io::stdin()
      .lines()
      .map(|x| x.unwrap())
      .collect()
}
