import boto3
import json

import optparse

global options,cft
argv = None
parser = optparse.OptionParser(usage="%prog", version="%prog 1.0")
parser.add_option("-r", "--region", dest="region", type="string",
                          default='us-east-1', help="Please Enter AWS Region")
parser.add_option("-g", "--globalnetworkid", dest="global_network_id", type="string",
                          default=None, help="Please Enter aws global network id")
parser.add_option("-c", "--corenetworkid", dest="coren_etwork_id", type="string",
                          default=None, help="Please Enter Core Network Id")
parser.add_option("-n", "--networkfunctiongroup", dest="networkfunctiongroup", type="string",
                          default=None, help="Please Enter Network Function Group")
# parser.add_option("-c", "--command", dest="command", type="string",
#                           default='@powershell $env:computername', help="Please Enter Powershell command to be executed on remote windows server")


# Initialize the Network Manager client
region = '<region>'  # e.g., 'us-west-2'
client = boto3.client('networkmanager', region_name=region)

# Define your CloudWAN parameters TODO: put this in to params
global_network_id = '<global-network-id>'  # e.g., 'global-network-1234567890abcdef0'
core_network_id = '<core-network-id>'      # e.g., 'core-network-0987654321fedcba0'
network_function_group_name = '<network-function-group-name>'  # e.g., 'FirewallGroup'

# Construct the RouteTableIdentifier for a NetworkFunctionGroup
route_table_identifier = {
    'CoreNetworkNetworkFunctionGroup': {
        'CoreNetworkId': core_network_id,
        'NetworkFunctionGroupName': network_function_group_name,
        'EdgeLocation' : "us-east-2"

    }
}

try:
    # Call get_network_routes to retrieve the route table details
    response = client.get_network_routes(
        GlobalNetworkId=global_network_id,
        RouteTableIdentifier=route_table_identifier
    )

    # Print the full response for debugging (optional)
    print("Full Response:")
    print(json.dumps(response, indent=2, default=str))

    # Extract and print key details
    route_table_id = response.get('RouteTableIdentifier')
    routes = response.get('NetworkRoutes', [])

    print("\nRoute Table Identifier:")
    print(route_table_id)

    print("\nRoutes:")
    for route in routes:
        print(f"Destination: {route.get('DestinationCidrBlock')}, "
              f"Target: {route.get('Target')}, "
              f"State: {route.get('State')}")

except client.exceptions.ClientError as e:
    print(f"Error: {e}")
