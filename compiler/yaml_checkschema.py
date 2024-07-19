"""
Parses a yaml file against the given schema,
with errors showing line number of error
in yaml file.
"""
import json
import sys
from urllib.request import urlopen
import yaml
from jsonschema import validate
from jsonschema.exceptions import ValidationError
from yaml.loader import Reader, Scanner, Parser, Composer, SafeConstructor, Resolver
from yaml.nodes import MappingNode


class StrictBoolSafeResolver(Resolver):
    """
    Do not transform "On/Off/Yes/No " in booleans
    """

# remove resolver entries for On/Off/Yes/No
for ch in "OoYyNn":
    if len(StrictBoolSafeResolver.yaml_implicit_resolvers[ch]) == 1:
        del StrictBoolSafeResolver.yaml_implicit_resolvers[ch]
    else:
        StrictBoolSafeResolver.yaml_implicit_resolvers[ch] = [x for x in
                StrictBoolSafeResolver.yaml_implicit_resolvers[ch]
                if x[0] != 'tag:yaml.org,2002:bool']


class StrictBoolSafeLoader(Reader, Scanner, Parser,
                           Composer, SafeConstructor, StrictBoolSafeResolver):
    """
    Custom loader to not transform bool like strings into booleans.
    """
    def __init__(self, stream):
        Reader.__init__(self, stream)
        Scanner.__init__(self)
        Parser.__init__(self)
        Composer.__init__(self)
        SafeConstructor.__init__(self)
        StrictBoolSafeResolver.__init__(self)


def line_from(path, yaml_file):
    """
    Return the line number in the yaml string
    that corresponds to the given path.
    """
    with open(yaml_file, "r", encoding="utf-8") as stream:
        node = yaml.compose(stream, Loader=StrictBoolSafeLoader)
    for item in path:
        index = 0
        for entry in node.value:
            if isinstance(entry, MappingNode):
                if index == item:
                    node = entry.value[1][0]
                    break
                index += 1
            elif entry[0].value == item:
                node = entry[1]
                break
        else:
            raise ValueError("unknown path element: " + item)
    return node.start_mark.line + 1


def download_schema(url):
    """
    Downloads the schema from the given url.
    """
    response = urlopen(url)
    body_bytes = response.read()
    body_string = body_bytes.decode('utf-8')
    parsed = json.loads(body_string)
    return parsed


def validate_yaml(schema_url, yaml_file):
    """
    Validates the yaml file.
    """
    schema_contents = download_schema(schema_url)
    with open(yaml_file, "r", encoding="utf-8") as stream:
        yaml_contents = yaml.load(stream, Loader=StrictBoolSafeLoader)
    try:
        validate(instance=yaml_contents, schema=schema_contents)
    except ValidationError as my_error:
        line = line_from(my_error.absolute_path, yaml_file)
        print(f"{yaml_file}:{line}: Error: {my_error.message}")


if __name__ == "__main__":
    validate_yaml(sys.argv[1], sys.argv[2])
