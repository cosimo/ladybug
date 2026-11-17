"""
Frame recorder runs comparison

Prints the frame ranges whose hashes differ between two runs of record.sh,
and exits with status 1 when any frame differs. With --bbox, it also prints
the bounding box of the changed pixels, for the frames that both runs dumped
with RECORD_DUMP.

    python3 tools/frame-recorder/compare.py before after --bbox
"""

import argparse
import sys
from pathlib import Path

RUNS_DIR = Path(__file__).parent / "runs"

# The game window, one window pixel per game pixel
FRAME_WIDTH, FRAME_HEIGHT = 192, 240

# Enough frame ranges to see where a change shows, without scrolling
MAX_RANGES_SHOWN = 40


def load_hashes(label: str) -> dict[int, str]:
    """
    Returns the md5 of each frame of a run, by frame number
    """
    hashes = {}

    for line in (RUNS_DIR / label / "out" / "hashes.txt").read_text().splitlines():
        frame_text, digest = line.split()
        hashes[int(frame_text)] = digest

    return hashes


def frame_ranges(frames: list[int]) -> list[tuple[int, int]]:
    """
    Returns the consecutive runs of a sorted list of frame numbers, as
    (first, last) pairs
    """
    ranges = []

    for frame in frames:
        if ranges and ranges[-1][1] == frame - 1:
            ranges[-1] = (ranges[-1][0], frame)
        else:
            ranges.append((frame, frame))

    return ranges


def changed_bbox(label_a: str, label_b: str, frame: int) -> str | None:
    """
    Returns the bounding box of the pixels that differ in a frame, as text,
    or None when either run didn't dump that frame
    """
    frame_name = f"frame-{frame:05d}.rgba"
    path_a = RUNS_DIR / label_a / "out" / frame_name
    path_b = RUNS_DIR / label_b / "out" / frame_name

    if not path_a.exists() or not path_b.exists():
        return None

    pixels_a = path_a.read_bytes()
    pixels_b = path_b.read_bytes()
    changed_x, changed_y = [], []

    for offset in range(0, len(pixels_a), 4):
        if pixels_a[offset : offset + 4] != pixels_b[offset : offset + 4]:
            pixel = offset // 4
            changed_x.append(pixel % FRAME_WIDTH)
            changed_y.append(pixel // FRAME_WIDTH)

    if not changed_x:
        return "identical"

    return f"x {min(changed_x)}..{max(changed_x)} y {min(changed_y)}..{max(changed_y)} ({len(changed_x)} pixels)"


def parse_args() -> argparse.Namespace:
    """
    Returns the command line arguments
    """
    parser = argparse.ArgumentParser(description="Compare the frame hashes of two record.sh runs")
    parser.add_argument("label_a", help="label of the first run, as given to record.sh")
    parser.add_argument("label_b", help="label of the second run")
    parser.add_argument("--bbox", action="store_true", help="print where the dumped frames differ")
    return parser.parse_args()


def main() -> int:
    """
    Returns 1 when any frame differs between the two runs, 0 otherwise
    """
    args = parse_args()

    hashes_a = load_hashes(args.label_a)
    hashes_b = load_hashes(args.label_b)
    common_frames = sorted(set(hashes_a) & set(hashes_b))
    differing = [frame for frame in common_frames if hashes_a[frame] != hashes_b[frame]]

    # A run that crashed halfway has fewer frames, and only the common ones
    # get compared
    if len(hashes_a) != len(hashes_b):
        print(f"{args.label_a} has {len(hashes_a)} frames, {args.label_b} has {len(hashes_b)}")

    print(f"{len(common_frames)} frames compared, {len(differing)} differ")

    ranges = frame_ranges(differing)
    for first, last in ranges[:MAX_RANGES_SHOWN]:
        print(f"  frames {first}..{last}")
    if len(ranges) > MAX_RANGES_SHOWN:
        print(f"  ...and {len(ranges) - MAX_RANGES_SHOWN} more ranges")

    if args.bbox:
        for frame in differing:
            bbox = changed_bbox(args.label_a, args.label_b, frame)
            if bbox is not None:
                print(f"  frame {frame}: {bbox}")

    return 1 if differing else 0


if __name__ == "__main__":
    sys.exit(main())
