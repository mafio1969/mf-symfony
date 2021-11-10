#!/bin/bash

sudo chmod 777 -R ./logs
sudo chmod 777 -R ./main/var
# sudo chmod 777 -R ./main/*.*
sudo chown "${USER}":docker -R ./main

exit 0
