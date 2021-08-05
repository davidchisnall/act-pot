#!/bin/sh
zfs promote zroot/pot/jails/$2-ephemeral/m
pot destroy -p $2
pot rename -p $1 -n $2
