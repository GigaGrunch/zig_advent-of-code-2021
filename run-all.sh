set -e

cd `dirname "$0"`
project_root=$(pwd)

cd "$project_root/day-1"
zig run "main.zig"

echo ""

cd "$project_root/day-2"
zig run "main.zig"

echo ""

cd "$project_root/day-3"
zig run "main.zig"

echo ""

cd "$project_root/day-4"
zig run "main.zig"
