import mysql.connector
from proxmoxer import ProxmoxAPI
import socket, binascii, os
from dotenv import load_dotenv

## Load env from file
    # Big block of info
    # .env template is provided in git
load_dotenv()
pmIp = os.getenv('pmIp')
pmUser = os.getenv('pmUser')
pmPass = os.getenv('pmPass')
mHost = os.getenv('mHost')
mUser = os.getenv('mUser')
mPass = os.getenv('mPass')
mDb = os.getenv('mDb')

# Chuddy way to do it lol

## Connect to proxmox
node = socket.gethostname()
px = ProxmoxAPI(pmIp, user=pmUser, password=pmPass, verify_ssl=False)
print(f"Logged into {px}, strap in....")

## Gets all the info needed and writes with WriteToMaria() 
def GetAndWrite():
    ## Enumerate over the whole Cluster
        # Node by node get all descirptions
    for vm in px.cluster.resources.get(type="vm"): # Ask api for all vms
        vmid = vm["vmid"] #vmid
        vm_node = vm["node"] #Node, important
#        print(vmid)
## Need to change for QM instead of LXC down the ling
        
        if vm["type"] == "qemu" and vmid >= 1000:
            Config = px.nodes(vm_node).qemu(vmid).config.get()
            CtTag = Config.get("tags") #Get all tags from the vm
            CtName = Config.get("name") #Changed from hostname (qemu convention)
            print(CtTag, CtName)
            if CtTag == "run": #If the LXC has the mgmt tag do not add it 
                #ctDesc = px.nodes(vm_node).qemu(vmid).config.get().get("description")
                ctDesc = Config.get("description")
 #               print(ctDesc)
                if ctDesc == None:
                    print(f"No Description Found on {vmid} D: \n (Go add one Evan)")
                    continue
                #interfaces = px.nodes(vm_node).lxc(vmid).interfaces.get()
                interfaces = px.nodes(vm_node).qemu(vmid).agent("network-get-interfaces").get() #Qemu VM get interface
  #              print(interfaces)
                ## Dont work with any blank interfaces 
                if not interfaces:
                    print(f"{vmid} Interface blank?? Check dih35")
                    continue

                for iface in interfaces.get("result", []):
                    for addr in iface.get("ip-addresses", []):
                        inet = addr.get("ip-address")
                        ipType = addr.get("ip-address-type")
   #                     print(inet)
                    # Get INET, will include 127 :(
                    #inet = iface["ip-address"]
                    #print(inet)
                        if ipType  == "ipv4" and inet and not inet.startswith("127."): ## DOnt select at interface that begins with 127. 
                            #ip = (iface.get("ip-address").split('/')[0])
                                ip = inet

                #print(f"VMID:{vmid}", f"User:{ctDesc.split(":")[0]}, Pass:{ctDesc.split(":")[1]}", f"INT:{ip}", f"TAG:{CtTag}")
                group = f"{int(str(vmid))//10}" ## Need to change to Full VMID (might work?) 
                WriteToMaria(f"{CtName}", "vnc", f"{ip}", f"{ctDesc.split(":")[0]}", f"{ctDesc.split(":")[1]}", 5901, group) ## CHange THIS A LOT 

        else: #Pass on the else case for mgmt
            continue


## Writes to MariaDB 
    # Horrible mess of a function
def WriteToMaria(conn_name, protocol, hostname, username, password, port, group):
    conn = mysql.connector.connect(
        host=mHost,
        user=mUser,
        password=mPass,
        database=mDb,
        ssl_disabled=True
    )

    try:
        ## Chud ass methods to write, SQL is so awesome guys!!! (redis lovers when)
        cursor = conn.cursor()
        
        ## Get Current Group    
            # SELECT connection_group_id  FROM guacamole_connection_group WHERE connection_group_name LIKE 200;
        ## Check if group exists with SELECT
        globCurrParent = 0 ## Current parent group 
        cursor.execute(f"SELECT EXISTS (SELECT * FROM guacamole_connection_group WHERE connection_group_name LIKE {group}) AS EXISTS_BY_NAME;") 
        out = (cursor.fetchall()[0][0]) # Get cursor data, fetch result
        if (out == 0):
            # Create Connection group
            cursor.execute(f"INSERT INTO guacamole_connection_group (connection_group_name) VALUES ({group});") ## Create Groups
            cursor.execute(f"SELECT connection_group_id  FROM guacamole_connection_group WHERE connection_group_name LIKE {group};") ## Get Group ID
            globCurrParent = cursor.fetchall()[0][0]
            print(f"Created Group {group}")
        else:
            cursor.execute(f"SELECT connection_group_id  FROM guacamole_connection_group WHERE connection_group_name LIKE {group};") ## Get Group ID
            globCurrParent = cursor.fetchall()[0][0]
            print(f"{group} Exists")

        # Create guac connection
        cursor.execute(f"INSERT INTO guacamole_connection (connection_name, protocol, parent_id) VALUES ('{conn_name.strip()}', '{protocol.strip()}', {globCurrParent});")
        
        last = cursor.lastrowid #Get last insert for database
        ## FUCK WHITE SPACES (thank you python for being so wonderfulllll)

        ### HAVE TO CHANGE TO VNC WHEN KALI IS READY
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'hostname', '{hostname.strip()}');")
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'username', '{username.strip()}');")
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'password', '{password.strip()}');")
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'port', '{port}');")
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'color-depth ', 16);")
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'compress-level', '3');")
        cursor.execute(f"INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value) VALUES ({last}, 'disable-display-resize', 'true');")

       
        #|             8 | clipboard-encoding     | UTF-8           |
        #|             8 | color-depth            | 16              |
        #|             8 | compress-level         | 3               |
        #|             8 | disable-display-resize | true
        
        
        print(f"{conn_name} Added :D")

    except Exception as e:
        conn.rollback() #Roll back on fail
        print("Error occurred. Transaction rolled back.")
        print(e)

    finally:
        conn.commit() 
        cursor.close()
        conn.close()

GetAndWrite()
