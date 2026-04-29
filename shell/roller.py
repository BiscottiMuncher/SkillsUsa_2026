from proxmoxer import ProxmoxAPI
import socket, binascii, os, time
from dotenv import load_dotenv

## Load env from file
    # Big block of info
    # .env template is provided in git
load_dotenv()
pmIp = os.getenv('pmIp')
pmUser = os.getenv('pmUser')
pmPass = os.getenv('pmPass')

# Chuddy way to do it lol

## Connect to proxmox
node = socket.gethostname()
px = ProxmoxAPI(pmIp, user=pmUser, password=pmPass, verify_ssl=False)
print(f"Logged into {px}, strap in....")

def GetAndRoll():
    for vm in px.cluster.resources.get(type="vm"): # Ask api for all vms
        vmid = vm["vmid"] #vmid
        vm_node = vm["node"] #Node, important
        if vm["type"] == "qemu" and vmid >= 1000:
            Config = px.nodes(vm_node).qemu(vmid).config.get()
            CtTag = Config.get("tags") #Get all tags from the vm
            if CtTag == "run" or CtTag == "cptc": #If the LXC has the mgmt tag do not add it
                px.nodes(vm_node).qemu(vmid).snapshot("IP-RIGHT").rollback.post(start=1)
                #px.nodes(vm_node).qemu(vmid).delete(**{"purge": 1,"destroy-unreferenced-
                print(f"Rolledback {vmid}, on {vm_node}")
        elif vm["type"] == "lxc" and vmid >= 1000:
            Config = px.nodes(vm_node).lxc(vmid).config.get()
            CtTag = Config.get("tags") #Get all tags from the vm
            if CtTag == "run" or CtTag == "cptc": #If the LXC has the mgmt tag do not add it
                px.nodes(vm_node).lxc(vmid).snapshot("READY").rollback.post(start=1)
                #px.nodes(vm_node).qemu(vmid).delete(**{"purge": 1,"destroy-unreferenced-disks": 1})
                print(f"Rolledback {vmid}, on {vm_node}")
        else: #Pass on the else case for mgmt
            continue

GetAndRoll()
