from proxmoxer import ProxmoxAPI
import socket, binascii, os
from dotenv import load_dotenv

print("Creating VMS through bash (nasty...)")
os.system("./PoolQm.sh")

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


counter = 1

def next_counter():
    global counter
    counter = (counter % 3) + 1
    return counter


## Gets all the info needed and writes with WriteToMaria() 
def GetAndKill():
    ## Enumerate over the whole Cluster
        # Node by node get all descirptions
    for vm in px.cluster.resources.get(type="vm"): # Ask api for all vms
        curr  = next_counter()
        vmid = vm["vmid"] #vmid
        vm_node = vm["node"] #Node, important
#        print(vm_node[:8])
## Need to change for QM instead of LXC down the ling
        if vm["type"] == "qemu" and vmid >= 1000:
#            print(vm["name"])
            Config = px.nodes(vm_node).qemu(vmid).config.get()
            CtTag = Config.get("tags") #Get all tags from the vm
            if CtTag == "run": #If the LXC has the mgmt tag do not add it
                target = f"{vm_node[:8]}{curr}"
                if target == vm_node:
                    continue
                px.nodes(vm_node).qemu(vmid).migrate.post(target=target)
                print(f"Migrated {vmid}")
        else: #Pass on the else case for mgmt
            continue

GetAndKill()
