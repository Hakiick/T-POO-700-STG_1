#!/bin/bash

sudo docker exec -it time-manager_db_1 bash -c "psql -U postgres -d time_manager"
