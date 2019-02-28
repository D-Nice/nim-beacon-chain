#!/bin/bash

set -eux

# Kill children on ctrl-c
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Read in variables
. $(dirname $0)/vars.sh

# Set a default value for the env vars usually supplied by nimbus Makefile

NUMBER_OF_VALIDATORS=99

cd $SIM_ROOT
mkdir -p "$SIMULATION_DIR"
mkdir -p "$STARTUP_DIR"

cd $GIT_ROOT
mkdir -p $BUILD_OUTPUTS_DIR

# Run with "SHARD_COUNT=4 ./start.sh" to change these
DEFS="-d:SHARD_COUNT=${SHARD_COUNT:-4} "      # Spec default: 1024
DEFS+="-d:SLOTS_PER_EPOCH=${SLOTS_PER_EPOCH:-8} "   # Spec default: 64
DEFS+="-d:SECONDS_PER_SLOT=${SECONDS_PER_SLOT:-6} " # Spec default: 6

if [ ! -f $STARTUP_FILE ]; then
  if [[ -z "$SKIP_BUILDS" ]]; then
    nim c -o:"$VALIDATOR_KEYGEN_BIN" $DEFS -d:release beacon_chain/validator_keygen
  fi

  $VALIDATOR_KEYGEN_BIN --validators=$NUMBER_OF_VALIDATORS --outputDir="$STARTUP_DIR"
fi

if [[ -z "$SKIP_BUILDS" ]]; then
  nim c -o:"$BEACON_NODE_BIN" $DEFS --opt:speed beacon_chain/beacon_node
fi

if [ ! -f $SNAPSHOT_FILE ]; then
  $BEACON_NODE_BIN createChain \
    --chainStartupData:$STARTUP_FILE \
    --out:$SNAPSHOT_FILE --genesisOffset=5 # Delay in seconds
fi

# Delete any leftover address files from a previous session
if [ -f $MASTER_NODE_ADDRESS_FILE ]; then
  rm $MASTER_NODE_ADDRESS_FILE
fi

# multitail support
MULTITAIL="${MULTITAIL:-multitail}" # to allow overriding the program name
USE_MULTITAIL="${USE_MULTITAIL:-no}" # make it an opt-in
type "$MULTITAIL" &>/dev/null || USE_MULTITAIL="no"
COMMANDS=()

for i in $(seq 0 8); do
  BOOTSTRAP_NODES_FLAG="--bootstrapNodesFile:$MASTER_NODE_ADDRESS_FILE"

  if [[ "$i" == "0" ]]; then
    sleep 0
  elif [ "$USE_MULTITAIL" = "no" ]; then
    # Wait for the master node to write out its address file
    while [ ! -f $MASTER_NODE_ADDRESS_FILE ]; do
      sleep 0.1
    done
  fi

  CMD="$SIM_ROOT/run_node.sh $i"

  if [ "$USE_MULTITAIL" != "no" ]; then
    if [ "$i" = "0" ]; then
      SLEEP="0"
    else
      SLEEP="2"
    fi
    # "multitail" closes the corresponding panel when a command exits, so let's make sure it doesn't exit
    COMMANDS+=( " -cT ansi -t 'node #$i' -l 'sleep $SLEEP; $CMD; echo [node execution completed]; while true; do sleep 100; done'" )
  else
    eval $CMD &
  fi
done

if [ "$USE_MULTITAIL" != "no" ]; then
  eval $MULTITAIL -s 3 -M 0 -x \"Nimbus beacon chain\" "${COMMANDS[@]}"
else
  wait # Stop when all nodes have gone down
fi
