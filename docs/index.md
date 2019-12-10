# Creating a RAID-5 or RAID-6 array from drives of dissimilar size

Normally creating a RAID-5 or RAID-6 array on a collection of drives of dissimilar
sizes will result in a RAID drive that's a multiple of the size of the smallest drive.
For example, if there are four drives of 8TB and one of 2TB, the array will be created
from 5 partitions of 2TB each, leaving 6TB unused on the four largest drives.

However, it is possible to get some resilience to drive failures whilst still
making use of most of the capacity of dissimilarly-sized drives.

This is not a new technique - Synology uses it for their 'Synology Hybrid RAID'
(SHR and SHR-2) volume formats.

To work around the constraint of the raid members needing to be the same size, 
the drives are divided into partitiaions of equal size. An array is then created
using the equally-sized partitions across the different physical drives.

In this manner, multiple RAID-5 or 6 arrays are created, spanning a variable
number of drives. The multiple RAID arrays can then be pooled together by using
them as LVM2 physical volumes, and adding them all to the same LVM2 volume group.</p>

## Drive Sizes - 1024 vs. 1000

Hard Drive vendors market their drive sizes in multiples of 1000, not 1024 as is
customary for everything else in the computer industry. To add to the confusion,
they use multiples of 1000 of sector sizes, which are 512 bytes each. So the result
uses neither one nor the other.

This is important, since an 8TB drive isn't 8 x 1024 x 1024 x 1024 x 1024 bytes, 
like it would be for RAM, it's 8 x 1000 x 1000 x 1000 x 1000 x 2 x 512 bytes. In
reality, a hard drive will exceed that capacity by a small margin, both in accessible
 size, plus a reserved area used for remapping sectors that 'go bad'.

For the purposes of sizing partitions, I use a count of 1953125000 sectors, each of
which holds 512 bytes, which equals 1,000,000,000,000 bytes, or '1TB' in HD marketing
 speak.

The script I've written allocates 2TB partitions until there is less than 2TB free
space remaining, and then checks to see if there is sufficient space to allocate
one more 1TB partition if sufficient space remains, and then one more partition 
with whatever space remains unallocated.

****
## Further Reading

* [sgdisk](http://www.rodsbooks.com/gdisk/) - used to partition the individual
 hard drives using the GPT partition table format.
* [lvm2](https://sourceware.org/lvm2/) - used to combine the multiple RAID arrays
into a volume group, a single large pool of storage blocks. Logical volumes can
then be created using storage from the pool provided by the volume group.