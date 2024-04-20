#!/bin/sh

# Capture ip route output
ip_route_output=$(ip route)

# Extract DEFAULT_GATEWAY and ETH_DEVICE
default_gateway_info=$(echo "$ip_route_output" | grep -Eo 'default via ([0-9.]+) dev ([a-z0-9]+)')

# Separate DEFAULT_GATEWAY and ETH_DEVICE
DEFAULT_GATEWAY=$(echo "$default_gateway_info" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
ETH_DEVICE=$(echo "$default_gateway_info" | grep -Eo '[^ ]+$')

echo "Added IP rule for default route (preference 200, table 200)"
ip rule add pref 100 from `hostname -i` lookup 200
ip route add default via $DEFAULT_GATEWAY dev $ETH_DEVICE table 200

# Initial preference and base table number
INIT_PREF=99

# Read network addresses from variable
#EXTRA_SUBNETS="$1"  # Assuming input is passed as the first argument

# Check if network addresses are provided
if [ -z "$EXTRA_SUBNETS" ]; then
  echo "No EXTRA_SUBNETS"
  exit 0
fi

# Loop through network addresses
echo "$EXTRA_SUBNETS" | sed 's/,/\n/g' | while read network; do
  # Check if network address is valid
  VALID=$(echo $network | egrep '^([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3})/([[:digit:]]{1,2})$');

  if [ ! -n "$VALID" ]; then
    echo "This Network ($network) isn't valid. Please check it and try again.";
    continue;
  fi;

  # Calculate preference and table number (table = preference + 100)
  pref=$((INIT_PREF--))
  table=$((pref + 100))

  # Add IP rule for the network
  ip rule add pref "$pref" from all to "$network" lookup "$table"
  echo "Added IP rule for $network (preference $pref, table $table)"

  # Add route for the network
  ip route add "$network" via "$DEFAULT_GATEWAY" dev "$ETH_DEVICE" table "$table"
  echo "Added route for $network via $DEFAULT_GATEWAY (table $table)"
done