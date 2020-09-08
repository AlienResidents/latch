#!/bin/bash

#
# Script to setup the chroot according to Latch.
#
#

latch_proto="http"
latch_host="127.0.0.1"
latch_port="80"

chroot_base=$(curl $latch_proto://$latch_host:$latch_port)

# Need to set up the chroot now with appropriate stuff, like packages etc.
