"""
Generate multiple 3D View with openscad
"""


import subprocess
import os
import math

if not os.path.isdir("views"):
    os.mkdir("views")

if not os.path.isdir("animation"):
    os.mkdir("animation")

DIST = 200
H_VIEW = 70
N_VIEW = 3
N_TURN = 1

WIDTH = 1920
HEIGHT = 1080

bin_option = {
    "gridx": 1,
    "gridy": 1,
    "gridz": 3,
    "compx": 1,
    "compy": 1,
    "tabs": False,
    "half_grid": False,
}

bin_options = [
    {},
    {"gridx": 2},
    {"gridx": 3},
    {"gridx": 4},
    {"gridx": 5},
    {"gridy": 2},
    {"gridy": 3},
    {"gridz": 2},
    {"gridz": 1},
    {"gridz": 2},
    {"gridz": 3},
    {"gridz": 4},
    {"gridz": 5},
    {"half_grid": True},
    {"compx": 2},
    {"compx": 3},
    {"compy": 2},
    {"tabs": True},
]

bp_option = {
    "gridx": 1,
    "gridy": 1,
    "half_grid": False,
    "disable_extra_half_x": True,
    "disable_extra_half_y": True,
}

bps_options = [
    {"gridx": 1},
    {"gridx": 2},
    {"gridx": 3},
    {"gridx": 4},
    {"gridx": 5},
    {"gridy": 2},
    {"gridy": 3},
    {"dix": 5.75 * 42, "diy": 3.75 * 42},
    {"fitx": 0.8},
    {"fity": 0.8},
    {"disable_extra_half_x": False},
    {"disable_extra_half_y": False},
    {"half_grid": True},
    {"half_grid": False},
    {"style_baseplate": 1},
    {"style_baseplate": 2},
    {"manufacturing": 1},
    {"style_baseplate": 1},
    {"style_baseplate": 0},
]


def pop_or_none(list_to_pop):
    """
    Pop a list. If the list is empty, return None
    """
    if len(list_to_pop) == 0:
        return None
    return list_to_pop.pop()


def convert_options_to_text(options):
    arg = ""
    for key, val in options.items():
        arg += f"-D {key}={val} ".replace("True", "true")
    print(arg)
    return arg


def create_animated_view(
    filename,
    standard_options,
    frames_options,
    width=1920,
    height=1080,
    x=100,
    y=100,
    z=100,
    append_name="",
):
    """
    For a given filename will generate multiple views for a animation
    """

    for idx, frame_option in enumerate(frames_options):
        for key, val in frame_option.items():
            if key != "frame":
                standard_options[key] = val
        text_options = convert_options_to_text(standard_options)

        return_code = subprocess.call(
            f"openscad --preview --camera={x},{y},{z},0,0,0 {filename} --autocenter -o views/{filename.replace('.scad','')}{'' if len(append_name) == 0 else '_' + append_name}_{idx}.png --imgsize={width},{height} --render --colorscheme=Solarized -q {text_options}",
            shell=True,
        )


def create_animated_rotation_view(
    filename,
    standard_options,
    frames_options,
    n_view=3,
    n_turn=1,
    width=1920,
    height=1080,
):
    """
    For a given filename will generate multiple views for a animation
    """
    # Convert the standard option to flag for the command line
    text_options = convert_options_to_text(standard_options)

    # Get the next option to apply
    curr_option = pop_or_none(frames_options)
    for i in range(n_view):
        # If we have options to change at this frame
        if curr_option is not None and i == curr_option["frame"]:
            # Update the standard options
            for key, val in curr_option.items():
                if key != "frame":
                    standard_options[key] = val
            # Convert it to flags for the command line
            text_options = convert_options_to_text(standard_options)
            # Get the next option to apply
            curr_option = pop_or_none(frames_options)

        # Rotate around a circle
        x = DIST * math.cos(n_turn * 2 * math.pi * i / n_view)
        y = DIST * math.sin(n_turn * 2 * math.pi * i / n_view)

        return_code = subprocess.call(
            f"openscad --preview --camera={x},{y},{H_VIEW},0,0,0 {filename} --autocenter -o views/test_{i}.png --imgsize={width},{height} --render --colorscheme=Solarized -q {text_options}",
            shell=True,
        )

    # Add text on picture ?

    # TODO save list of picture to gif for README


create_animated_view("baseplate.scad", bp_option, bps_options, x=0, y=300, z=300)

create_animated_view("bins.scad", bin_option, bin_options, x=200, y=400, z=300)
