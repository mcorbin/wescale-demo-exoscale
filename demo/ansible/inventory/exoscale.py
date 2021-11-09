#!/usr/bin/env python

# Ansible dynamic inventory for cloudstack

from cs import CloudStack, read_config
import sys
import json

def get_groups(vm):
    """Returns the ansible groups list for this VM"""
    group_tag = [x for x in vm["tags"] if x["key"] == "ansible_groups"]
    if group_tag:
        return group_tag[0]["value"].split(",")
    return []

def get_hostvars(vm):
    """Returns VM hostvars"""

    # TODO this will fail if an instance does not have a default nic
    # ipv6 ?
    default_nic = [nic for nic in vm["nic"] if nic["isdefault"]][0]
    return {
            "ansible_ssh_host": default_nic["ipaddress"],
            "ansible_host": default_nic["ipaddress"],
            "zone": vm["zonename"]
    }

def to_json(in_dict):
    return json.dumps(in_dict, sort_keys=True, indent=2)

def main():
    inventory = {
        "_meta": {
            "hostvars": {}
        }
    }

    try:
        cs = CloudStack(**read_config())
        vms = cs.listVirtualMachines()["virtualmachine"]

        for vm in vms:
            name = vm["name"]
            groups = get_groups(vm)
            for group in groups:
                # test if group already present in inventory
                if group in inventory:
                    inventory[group]["hosts"].append(name)
                else:
                    inventory[group] = {
                        "hosts": [name]
                    }
            inventory["_meta"]["hostvars"][name] = get_hostvars(vm)

        print(to_json(inventory))
    except Exception as e:
        sys.stderr.write('%s\n' % e.message)
        sys.exit(1)
    sys.exit(0)

if __name__ == '__main__':
    main()

