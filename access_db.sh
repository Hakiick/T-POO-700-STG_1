#!/bin/bash

sudo docker exec -it time-manager-db-1 bash -c "psql -U postgres -d time_manager"
