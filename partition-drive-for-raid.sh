#!/bin/bash

set -x

drive=$1

# sectors
onetb=1953125000
twotb=3906250000
raidType=fd00

sgdisk --zap-all $drive
sgdisk --clear $drive

first=`sgdisk --first-aligned-in-largest $drive`
end=`sgdisk --end-of-largest $drive`
let remaining=$end-$first

while [[ $remaining -gt $twotb ]]
do
  sgdisk --new=0:0:+$twotb --typecode=0:$raidType $drive

  first=`sgdisk --first-aligned-in-largest $drive`

  if [[ $first -lt $twotb ]]
  then
   exit
  fi

  let remaining=$end-$first

done

while [[ $remaining -gt $onetb ]]
do
  sgdisk --new=0:0:+$onetb --typecode=0:$raidType $drive

  first=`sgdisk --first-aligned-in-largest $drive`
  let remaining=$end-$first

done

# whatever's left, make it into a partition
sgdisk --new=0:0:0 --typecode=0:$raidType $drive

partprobe $drive
gdisk -l $drive

