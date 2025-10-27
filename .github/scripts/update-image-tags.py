#! /usr/bin/env python3
import argparse
import os
import re

from ruamel.yaml import YAML

yaml = YAML(typ='rt')
yaml.default_flow_style = False

def update_image_tags(file_path: str, image: str, old_tag: str, new_tag: str):
    """
    Update the image tag in a YAML file.
    
    Determine the format of the image speficication and update the tag
    accordingly.  Some image tags are in their own YAML field, while others are
    part of the image name (eg: /path/to/image:tag).

    :param file_path: Path to the YAML file.
    :param image: The full image path and name to update (e.g., 'nginx').
    :param old_tag: The old tag to be replaced (e.g., 'abc123def456').
    :param new_tag: The new tag to replace with (e.g., 'zyx098vut765').
    """
    with open(file_path, 'r') as file:
        data = yaml.load(file)

    def update_dict(d):
        for key, value in d.items():
            if isinstance(value, dict):
                update_dict(value)
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        update_dict(item)
            elif isinstance(value, str):
                # Check for image field with separate tag
                if key == 'image' and value.startswith(image + ':'):
                    parts = value.split(':')
                    if len(parts) == 2 and parts[1] == old_tag:
                        d[key] = f"{parts[0]}:{new_tag}"
                # Check for image field with embedded tag
                elif value.startswith(image + ':'):
                    parts = value.split(':')
                    if len(parts) == 2 and parts[1] == old_tag:
                        d[key] = f"{parts[0]}:{new_tag}"
                # Check for image field with digest
                elif re.match(rf'^{re.escape(image)}@sha256:[a-f0-9]+$', value):
                    continue  # Skip digest updates
                # Check for separate tag field
                elif key == 'tag' and d.get('image', '').startswith(image):
                    if value == old_tag:
                        d[key] = new_tag

    update_dict(data)

    with open(file_path, 'w') as file:
        yaml.dump(data, file)