import itertools
import os
import sys

def parse_key_value_file(file_path):
    key_value_dict = {}

    with open(file_path, 'r') as file:
        for line in file:
            # Strip leading/trailing whitespace from the line
            stripped_line = line.strip()

            # Ignore blank lines or lines that start with #
            if not stripped_line or stripped_line.startswith('#'):
                continue

            # Split the line by the first occurrence of '='
            if '=' in stripped_line:
                key, value = map(str.strip, stripped_line.split('=', 1))
                key_value_dict[key] = value

    return key_value_dict

def calc_diff(d1: dict[str, str], d2: dict[str, str]):
    out = ""

    for k in sorted(list(set(d1.keys()).union(set(d2.keys())))):
        left = None
        right = None

        if k in d1:
            left = d1[k]
        if k in d2:
            right = d2[k]

        if left is None and right is not None:
            out += f"--> {k}={right}\n"
        elif left is not None and right is None:
            out += f"{k}={left} <--\n"
        elif left != right:
            out += f"{k}={left} <--> {k}={right}\n"

    return out

def main(files: list[str]):
    config_dicts = []

    for f in files:
        assert type(f) == str
        fname = os.path.basename(f)
        config_dicts.append((fname, parse_key_value_file(f)))

    for ((f1, d1), (f2, d2)) in itertools.combinations(config_dicts, 2):
        print(f"Comparing {f1} vs. {f2}")
        print(calc_diff(d1, d2), end='')

if __name__ == '__main__':
    main(sys.argv[1:])

