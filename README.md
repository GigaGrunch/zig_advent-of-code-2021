# Advent of Code 2021 in Zig

## What is this?
* [Advent of Code](https://adventofcode.com/2021) is an advent calendar for programmers that has two puzzle each day, wrapped with a nice little story about saving christmas.
* [Zig](https://ziglang.org) is an awesome programming language and you should use it, too!

## Project structure
* Each day has its own zig file like `day-1.zig`.
* There is also a `all-days.zig` that runs all days.
* My personal input texts that I got from advent of code are also stored for each day.
* In some cases, I also added the sample input from the puzzle's explanation for testing. That can be used with a simple boolean switch at the top of the day's zig file.
* The solution of the seconds puzzle of a day might replace the first one, but I've created git tags for each solution so you can always go back to the first one.

## How to run
* [Download and install Zig](https://ziglang.org/learn/getting-started), but note that I am using the latest build of the master branch in december 2021.
* In a shell, execute `zig run day-X.zig` where X is a number for a day or simply execute `zig run all-days.zig` instead.
