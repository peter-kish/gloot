import xml.etree.ElementTree as ET

def xml_to_md(xml_file: str, md_file: str) -> None:
    save_md(load_xml(xml_file), md_file)

def load_xml(xml_file: str) -> dict:
    tree = ET.parse(xml_file)
    root = tree.getroot()
    class_data = {}
    
    get_attrib_to_dict(root, "name", class_data)
    get_attrib_to_dict(root, "inherits", class_data)
    for e in root:
        if e.tag == "brief_description":
            if len(e.text) > 0:
                class_data["brief_description"] = e.text.strip()
        elif e.tag == "description":
            if len(e.text) > 0:
                class_data["description"] = e.text.strip()
        elif e.tag == "methods":
            methods = extract_methods(e)
            if len(methods) > 0:
                class_data["methods"] = methods
        elif e.tag == "members":
            members = extract_members(e)
            if len(members) > 0:
                class_data["members"] = members
        elif e.tag == "signals":
            signals = extract_signals(e)
            if len(signals) > 0:
                class_data["signals"] = signals

    return class_data

def extract_methods(methods_element: ET.Element) -> list:
    result = []
    for method in methods_element:
        method_dict = extract_method(method)
        if method_dict:
            result.append(method_dict)
    return result

def extract_method(method_element: ET.Element) -> dict:
    result = {}
    get_attrib_to_dict(method_element, "name", result)
    if is_name_private(result["name"]):
        return {}
    get_attrib_to_dict(method_element, "qualifiers", result)
    get_subelement_attr_to_dict(method_element, "return", "type", result)
    get_subelement_text_to_dict(method_element, "description", result)
    method_params_list = extract_method_params(method_element)
    if len(method_params_list) > 0:
        result["params"] = method_params_list
    return result

def extract_method_params(method_element: ET.Element) -> list:
    result = []
    for e in method_element:
        if e.tag != "param":
            continue
        param = {}
        get_attrib_to_dict(e, "name", param)
        if is_name_private(param["name"]):
            continue
        get_attrib_to_dict(e, "type", param)
        get_attrib_to_dict(e, "default", param)
        result.append(param)
    return result

def extract_members(members_element: ET.Element) -> list:
    result = []
    for member in members_element:
        member_dict = extract_member(member)
        if member_dict:
            result.append(member_dict)
    return result

def extract_member(member_element: ET.Element) -> dict:
    result = {}
    get_attrib_to_dict(member_element, "name", result)
    if is_name_private(result["name"]):
        return {}
    get_attrib_to_dict(member_element, "type", result)
    get_attrib_to_dict(member_element, "default", result)
    if member_element.text:
        result["description"] = member_element.text.strip()
    return result

def extract_signals(signals_element: ET.Element) -> list:
    result = []
    for signal in signals_element:
        signal_dict = extract_signal(signal)
        if signal_dict:
            result.append(signal_dict)
    return result

def extract_signal(signal_element: ET.Element) -> dict:
    result = {}
    get_attrib_to_dict(signal_element, "name", result)
    get_subelement_text_to_dict(signal_element, "description", result)
    signal_params_list = extract_signal_params(signal_element)
    if len(signal_params_list) > 0:
        result["params"] = signal_params_list
    return result

def extract_signal_params(signal_element: ET.Element) -> list:
    result = []
    for e in signal_element:
        if e.tag != "param":
            continue
        param = {}
        get_attrib_to_dict(e, "name", param)
        if is_name_private(param["name"]):
            continue
        result.append(param)
    return result

def get_subelement_attr_to_dict(element: ET.Element, subelement_tag: str, attr_name: str, d: dict) -> None:
    for e in element:
        if e.tag != subelement_tag:
            continue
        if attr_name in e.attrib:
            d[attr_name] = e.attrib[attr_name]
            return

def get_subelement_text_to_dict(element: ET.Element, subelement_tag: str, d: dict) -> None:
    for e in element:
        if e.tag != subelement_tag:
            continue
        d[subelement_tag] = e.text.strip()
        return

def get_attrib_to_dict(element: ET.Element, attr_name: str, d: dict) -> None:
    if attr_name in element.attrib:
        d[attr_name] = element.attrib[attr_name]

def is_name_private(name: str) -> bool:
    return name[0] == '_'

def save_md(cd: dict, file_path: str) -> None:
    with open(file_path, "w") as f:
        write_header(f, cd)
        write_members(f, cd)
        write_methods(f, cd)
        write_signals(f, cd)
        print(f"{file_path} saved.")

def write_header(f, cd: dict):
    f.write(f"# `{cd["name"]}`\n\n")
    f.write(f"Inherits: `{cd["inherits"]}`\n\n")

    f.write("## Description\n\n")
    f.write(f"{cd["brief_description"]}\n\n")
    f.write(f"{cd["description"]}\n\n")

def write_members(f, cd: dict):
    if not "members" in cd:
        return

    f.write("## Properties\n\n")
    for member in cd["members"]:
        f.write(f"* `{member["name"]}: {member["type"]}` - {member["description"]}\n")
    f.write("\n")

def write_methods(f, cd: dict):
    if not "methods" in cd:
        return

    f.write("## Methods\n\n")
    for method in cd["methods"]:
        f.write(f"* `{method["name"]}(")
        if "params" in method:
            first = True
            for param in method["params"]:
                if not first:
                    f.write(", ")
                f.write(f"{param["name"]}: {param["type"]}")
                first = False
        f.write(f") -> {method["type"]}` - {method["description"]}\n")
    f.write("\n")

def write_signals(f, cd: dict):
    if not "signals" in cd:
        return

    f.write("## Signals\n\n")
    for signal in cd["signals"]:
        f.write(f"* `{signal["name"]}(")
        if "params" in signal:
            first = True
            for param in signal["params"]:
                if not first:
                    f.write(", ")
                f.write(f"{param["name"]}")
                first = False
        f.write(f")` - {signal["description"]}\n")
    f.write("\n")
