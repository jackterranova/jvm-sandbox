### Overview

Exploring verbose GC and affects of heap size.

Particularly interesting are the differences in both output format and results between JVM versions (like 8 vs 12).

### GC Flags

The default GC implementation usually changes from JVM version to JVM version.

Checking which GC is being used is a matter of specifying the correct command line flag.  But flags tend to change from JVM version to JVM version.

The param `-verbose`

### On this branch

This is a just a setup of running a program that attempts to use some memory and see what happens during GC if GC actually happens.

In subsequent branches, we'll make the program more memory intensive, use different GC implementations and add instrumentation.

### Results of this branch

A few interesting things to note from the output:

``

### Raw output of this branch

`Java 8` by default uses the `Parallel GC`, we see a lot of  

`GC (Allocation Failure)  512K->360K(1536K)`

^^^ This indicates a GC occurred.  In particular, this is a `partial` or `minor` GC.  As opposed to a `Full GC`.  Minor GCs clear out `Young generation` space - space occupied by objects that do not survive GC cycles (as opposed to space used by older objects - those that survive multiple GC cycles).  `Minor` GCs are always triggered when there isn't enough space to allocate a new object (`allocation failed`).    

The output also shows how much space was cleared by the GC.  In this case occupied heap was reduced from 512k to 360k.  1536K is the capacity of the heap and you can see its the same all the way down.

With `Java 12`, we can't even get the application to run.

With 1M max heap...

`Too small maximum heap`

Is this an issue with the default GC in 12?  Are the same GCs in 8 available in 12?

And with 2M max heap ...

`GC triggered before VM initialization completed. Try increasing NewSize, current value 1331K.`

The error is self explanatory.  Does Java 12 just use more memory than 8? 


```
Compiling and running with Java 8 ... 

OPTS -Xms1m -Xmx1m:
[GC (Allocation Failure)  512K->360K(1536K), 0.0007533 secs]
[GC (Allocation Failure)  872K->392K(1536K), 0.0008609 secs]
[GC (Allocation Failure)  904K->312K(1536K), 0.0009209 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0037868 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0015968 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0008678 secs]
[GC (Allocation Failure)  856K->296K(1536K), 0.0009479 secs]
[GC (Allocation Failure)  808K->328K(1536K), 0.0004289 secs]
[GC (Allocation Failure)  840K->296K(1536K), 0.0003349 secs]
[GC (Allocation Failure)  808K->336K(1536K), 0.0003896 secs]
[GC (Allocation Failure)  848K->344K(1536K), 0.0003003 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0011030 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0005860 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004841 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0005010 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0008595 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0007768 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0008773 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0016182 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0009824 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004083 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003826 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003892 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003921 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004105 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003854 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003683 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004006 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004367 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004204 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004686 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004458 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003638 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004327 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003734 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003750 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003871 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004195 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003103 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003256 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003074 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0002841 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003411 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004401 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003092 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003189 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0002673 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003408 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003467 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003104 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0006902 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0012027 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004282 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0007794 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004463 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004249 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004156 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003210 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003222 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003268 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003156 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0002910 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003249 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003373 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003202 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0002737 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003634 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003058 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003109 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003511 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003789 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0002674 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003898 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003015 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004046 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0009482 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0007950 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0012175 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004058 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003497 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003506 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003048 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003283 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003581 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003467 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003129 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003465 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003054 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0002987 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003658 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003767 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003066 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003212 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003610 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003499 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003065 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004465 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0010550 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004227 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003219 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003995 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003388 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0002951 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003254 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0005716 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0007310 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004475 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0006055 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003981 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004010 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004074 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004862 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003386 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003300 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003182 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003896 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0009228 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0006148 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004254 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0009079 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003245 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003226 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004142 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003538 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0002999 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003312 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003050 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004541 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003181 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003414 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003619 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003179 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0002916 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003957 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0002981 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003045 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0002808 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0002809 secs]
DONE

OPTS -Xms1m -Xmx2m:
[GC (Allocation Failure)  512K->392K(1536K), 0.0006821 secs]
[GC (Allocation Failure)  904K->360K(1536K), 0.0008361 secs]
[GC (Allocation Failure)  872K->344K(1536K), 0.0011135 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0007347 secs]
[GC (Allocation Failure)  824K->376K(1536K), 0.0009165 secs]
[GC (Allocation Failure)  888K->408K(1536K), 0.0007123 secs]
[GC (Allocation Failure)  920K->296K(1536K), 0.0008512 secs]
[GC (Allocation Failure)  808K->296K(1536K), 0.0004300 secs]
[GC (Allocation Failure)  808K->296K(1536K), 0.0005300 secs]
[GC (Allocation Failure)  808K->368K(1536K), 0.0004273 secs]
[GC (Allocation Failure)  880K->344K(1536K), 0.0012161 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004584 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004176 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0005144 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0005322 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004855 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0005626 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004797 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0005849 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0025484 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0006324 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003594 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004451 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004093 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003184 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003248 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004279 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0008277 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0006529 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0005166 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0006214 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003699 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0005633 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003496 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003396 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003586 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003995 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003379 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0002797 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004831 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003365 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003294 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003306 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003156 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003591 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003020 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003469 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003326 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0002961 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003375 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003004 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0002931 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003085 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004058 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003709 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0004507 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003440 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003694 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003714 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003943 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004207 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0007337 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0006234 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004105 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0007777 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0008067 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004296 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003299 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003156 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003910 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003952 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004023 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003671 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003215 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003243 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003162 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003221 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004249 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003047 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003207 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003247 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003154 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003799 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003205 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004615 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0008722 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0011378 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0005835 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003675 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003989 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003246 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003059 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003397 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003067 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004120 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003728 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004257 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0005176 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0004451 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003886 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0004332 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0012583 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0004163 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003464 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003102 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003259 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0005417 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003671 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003258 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003182 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003667 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003372 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003893 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003388 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003042 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003435 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003276 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003078 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0002824 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003518 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0008540 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0006299 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0005125 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0007555 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003900 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003231 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003828 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003588 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0002913 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003581 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003318 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003420 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003149 secs]
[GC (Allocation Failure)  824K->344K(1536K), 0.0003602 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003159 secs]
[GC (Allocation Failure)  856K->344K(1536K), 0.0003838 secs]
[GC (Allocation Failure)  856K->312K(1536K), 0.0003486 secs]
[GC (Allocation Failure)  824K->312K(1536K), 0.0003359 secs]
DONE
Compiling and running with Java 12 ... 

OPTS -Xms1m -Xmx1m:
Error occurred during initialization of VM
Too small maximum heap

OPTS -Xms1m -Xmx2m:
[0.010s][info][gc] Using G1
Error occurred during initialization of VM
GC triggered before VM initialization completed. Try increasing NewSize, current value 1331K.
```  



