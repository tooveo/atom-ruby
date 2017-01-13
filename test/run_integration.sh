#!/usr/bin/env bash -x
echo "Event count: ${EVENT_COUNT}"
ruby ./test/integration_test_atom_sdk.rb "${STREAM}" "${AUTH}" ${EVENT_COUNT} ${BULK_SIZE} ${BULK_SIZE_BYTE} "${DATA_TYPES}" "${DATA_INCREMENT_KEY}"  