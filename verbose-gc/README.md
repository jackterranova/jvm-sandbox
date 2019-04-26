### Overview

Exploring verbose GC and affects of heap size.

Particularly interesting are the differences in both output format and results between JVM versions (like 8 vs 12).

### GC overview

JVM memory is divided in to 3 parts

    * Young gen
      * Eden
      * Survivor 1
      * Survivor 2
    * Old gen
    * Perm gen (static data and meta data related to class-loaded classes)
    
Is this ^^^ all still true in Java 8?  
  
* In Java 8, `Metaspace` replaces `Perm Gen`
* `PermGen` was notorious for causing `OutOfMemoryException`.  `PermGen` was always limited in size relative to the heap and thus class loaders were not properly GC'ed 
* `Metaspace` will grow automatically when needed.  GC of class loading also improved.

### GC Flags

The default GC implementation usually changes from JVM version to JVM version.

Checking which GC is being used is a matter of specifying the correct command line flag.  But flags tend to change from JVM version to JVM version.

`-verbose:gc` provides basic verbose gc logging. 

`-XX:+PrintGCDetails` provides more detailed gc logging. Deprecated after Java 8.  Replaced by `-Xlog:gc*`

Depending on the JVM version, the logging may simply state what GC implementation is being used.  

If the logging does not supply the type of GC, `-XX:+PrintCommandLineFlags` will show any default values used, including the type of GC.    

GC logging in `Java 8` does not explicitly state GC type - use `-XX:+PrintCommandLineFlags`

### In the previous branch (01-verbose-gc-setup)

** Summary **

`-verbose:gc` the most basic way to log gc 
`-XX:+PrintGCDetails` a more detailed way to log gc
`-XX:+PrintCommandLineFlags` will print command line options both default and explicitly set params
`Parallel GC` default gc used in `Java 8`
`GC (Allocation Failure)` logging that indicates a `minor GC`
`Minor GC` reclaiming of heap occupied by young generation objects
`Full GC` reclaiming both old and young gen heap  
`G1` default gc used in Java 12 

### On this branch

We will dig deeper in to the details of the `Java 8` `Parallel GC` output and `Java 12` `GC1` output.  
  
### Results of this branch

A few interesting things to note from the output:

__Java 8__

`Java 8` by default uses the `Parallel GC`, we see a lot of  

`GC (Allocation Failure)`

^^^ This indicates a GC occurred.  In particular, this is a `partial` or `minor` GC.  As opposed to a `Full GC`.  Minor GCs clear out `Young generation` space - space occupied by objects that do not survive GC cycles (as opposed to space used by older objects - those that survive multiple GC cycles).  `Minor` GCs are always triggered when there isn't enough space to allocate a new object (`allocation failed`).    

`GC (Allocation Failure) [PSYoungGen: 512K->368K(1024K)] 512K->376K(1536K)`

The output also shows how much space was cleared by the GC.  In this case occupied heap was reduced from 512k to 376k.  1536K is the capacity of the heap and you can see its the same all the way down.

Additionally you see that the Young Generation space was reduced from 512k to 368k with a 1024k partition size. 

__Java 12__

With `Java 12`, we can't even get the application to run.

With 1M max heap...

`Too small maximum heap`  

`Java 12` uses `G1` ("Garbage-First") by default.  Although `Oracle` docs do not show a specific min heap max value, this is most likely a limitation of `G1`. 

And with 2M max heap ...

`GC triggered before VM initialization completed. Try increasing NewSize, current value 1331K.`

This error is self explanatory, but not necessarily the cause.  Most likely `Java 12` just uses more memory.      

### Questions   

* We specify `Xmx1m` yet we see the total heap space to be 1.5M.  Why is this?
* What exactly is our test program doing?  
* How much memory is being consumed in the loop? 
* Why is GC happening at 500k/800k points? 

### Raw output of this branch

```
Compiling and running with Java 8 ... 

OPTS -XX:+PrintCommandLineFlags -XX:+PrintGCDetails -Xms1m -Xmx1m:
-XX:InitialHeapSize=1048576 -XX:MaxHeapSize=1048576 -XX:+PrintCommandLineFlags -XX:+PrintGCDetails -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseParallelGC 
[GC (Allocation Failure) [PSYoungGen: 512K->368K(1024K)] 512K->376K(1536K), 0.0009455 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 880K->336K(1024K)] 888K->344K(1536K), 0.0007998 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 848K->304K(1024K)] 856K->312K(1536K), 0.0025784 secs] [Times: user=0.01 sys=0.01, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 816K->352K(1024K)] 824K->360K(1536K), 0.0011055 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 864K->320K(1024K)] 872K->328K(1536K), 0.0008305 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 832K->304K(1024K)] 840K->312K(1536K), 0.0007187 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 816K->32K(1024K)] 824K->336K(1536K), 0.0008228 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 848K->336K(1536K), 0.0004144 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 848K->336K(1536K), 0.0004109 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 848K->336K(1536K), 0.0004970 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 848K->344K(1536K), 0.0006562 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004460 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0006978 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005477 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005354 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0012517 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0022155 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005267 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005008 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0005778 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004347 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003288 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004059 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005871 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004599 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004034 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003730 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003865 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004852 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0013687 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004410 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004130 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004043 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004349 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005241 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004297 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004247 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0006848 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004151 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003635 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003337 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003113 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0002848 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003477 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004363 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0005662 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005555 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004574 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0006140 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004090 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004080 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0006178 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004458 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003695 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0008835 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004186 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003903 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003255 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003565 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003227 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004011 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0022728 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0007160 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004700 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003613 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004054 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003742 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003463 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003445 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004789 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003109 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003528 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003444 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003650 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003025 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003399 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004158 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003670 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0009198 secs] [Times: user=0.00 sys=0.01, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003514 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003460 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003348 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003409 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0002861 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003000 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003826 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003158 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004050 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004556 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003064 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003136 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003593 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003607 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004265 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0005307 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004825 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004250 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0006907 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004421 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004618 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004222 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0007044 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003782 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003137 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004120 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004866 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003351 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003359 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003951 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004167 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003048 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003601 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003254 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003174 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004410 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004585 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0017209 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0010941 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0010681 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004407 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0003759 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003333 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003215 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0003374 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0002984 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004074 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0006446 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0009672 secs] [Times: user=0.01 sys=0.01, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0004174 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004227 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004309 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004254 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->312K(1536K), 0.0004681 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003830 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 824K->312K(1536K), 0.0003352 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 824K->344K(1536K), 0.0004043 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0004488 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 856K->344K(1536K), 0.0003372 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
DONE
Heap
 PSYoungGen      total 1024K, used 350K [0x00000007bfe80000, 0x00000007c0000000, 0x00000007c0000000)
  eden space 512K, 62% used [0x00000007bfe80000,0x00000007bfecf820,0x00000007bff00000)
  from space 512K, 6% used [0x00000007bff80000,0x00000007bff88000,0x00000007c0000000)
  to   space 512K, 0% used [0x00000007bff00000,0x00000007bff00000,0x00000007bff80000)
 ParOldGen       total 512K, used 312K [0x00000007bfe00000, 0x00000007bfe80000, 0x00000007bfe80000)
  object space 512K, 60% used [0x00000007bfe00000,0x00000007bfe4e050,0x00000007bfe80000)
 Metaspace       used 2650K, capacity 4486K, committed 4864K, reserved 1056768K
  class space    used 286K, capacity 386K, committed 512K, reserved 1048576K

OPTS -XX:+PrintCommandLineFlags -XX:+PrintGCDetails -Xms1m -Xmx2m:
-XX:InitialHeapSize=1048576 -XX:MaxHeapSize=2097152 -XX:+PrintCommandLineFlags -XX:+PrintGCDetails -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseParallelGC 
[GC (Allocation Failure) [PSYoungGen: 512K->384K(1024K)] 512K->392K(1536K), 0.0007802 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 896K->368K(1024K)] 904K->376K(1536K), 0.0008061 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 880K->304K(1024K)] 888K->312K(1536K), 0.0009216 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 816K->320K(1024K)] 824K->328K(1536K), 0.0007288 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 832K->304K(1024K)] 840K->312K(1536K), 0.0008840 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 816K->336K(1024K)] 824K->344K(1536K), 0.0006919 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 848K->0K(1024K)] 856K->304K(1536K), 0.0008611 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 816K->304K(1536K), 0.0004270 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 816K->304K(1536K), 0.0004131 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 816K->344K(1536K), 0.0004878 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 856K->320K(1536K), 0.0004737 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0004712 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004167 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0005870 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0005477 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0005936 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004963 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004093 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004088 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0008740 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0007120 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0005298 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0006827 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003287 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003224 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0005048 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0008029 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0005234 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0005278 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004129 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003477 secs] [Times: user=0.00 sys=0.01, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004118 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004608 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003371 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003341 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003038 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003216 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0005069 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003658 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003384 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003157 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003289 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0004034 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003828 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003205 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003063 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003359 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003606 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003638 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003415 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003473 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003627 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0005161 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003614 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003494 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003323 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003401 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0004015 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003478 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0002794 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003113 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0002922 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0002855 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0005180 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0013095 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0005233 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0004432 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004426 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004413 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0006191 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003976 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0005280 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003362 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003133 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003497 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003594 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004402 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003521 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003428 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004565 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003714 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0008446 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0006901 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0005110 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0005057 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003269 secs] [Times: user=0.00 sys=0.01, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003956 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003363 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003267 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003641 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0004219 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003200 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003722 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003344 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003505 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003222 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0007718 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0006743 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0007891 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003384 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003597 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003421 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0002816 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003248 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004526 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0004257 secs] [Times: user=0.01 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003181 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0002932 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0004508 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0007577 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004409 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0004174 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0007815 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004224 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0004278 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004229 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003956 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003670 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003709 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003651 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003676 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0004184 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003603 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0004901 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0003452 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0002739 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003212 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003715 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003544 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0003039 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0002732 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0004105 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->0K(1024K)] 864K->320K(1536K), 0.0003444 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003046 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->0K(1024K)] 832K->320K(1536K), 0.0003530 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 512K->32K(1024K)] 832K->352K(1536K), 0.0004386 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0010540 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 544K->32K(1024K)] 864K->352K(1536K), 0.0006272 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
DONE
Heap
 PSYoungGen      total 1024K, used 350K [0x00000007bfe80000, 0x00000007c0000000, 0x00000007c0000000)
  eden space 512K, 62% used [0x00000007bfe80000,0x00000007bfecf820,0x00000007bff00000)
  from space 512K, 6% used [0x00000007bff80000,0x00000007bff88000,0x00000007c0000000)
  to   space 512K, 0% used [0x00000007bff00000,0x00000007bff00000,0x00000007bff80000)
 ParOldGen       total 512K, used 320K [0x00000007bfe00000, 0x00000007bfe80000, 0x00000007bfe80000)
  object space 512K, 62% used [0x00000007bfe00000,0x00000007bfe50050,0x00000007bfe80000)
 Metaspace       used 2650K, capacity 4486K, committed 4864K, reserved 1056768K
  class space    used 286K, capacity 386K, committed 512K, reserved 1048576K
Compiling and running with Java 12 ... 

OPTS -XX:+PrintGCDetails -Xms1m -Xmx1m:
[0.003s][warning][gc] -XX:+PrintGCDetails is deprecated. Will use -Xlog:gc* instead.
[0.015s][info   ][gc,heap] Heap region size: 1M
Error occurred during initialization of VM
Too small maximum heap

OPTS -XX:+PrintGCDetails -Xms1m -Xmx2m:
[0.002s][warning][gc] -XX:+PrintGCDetails is deprecated. Will use -Xlog:gc* instead.
[0.009s][info   ][gc,heap] Heap region size: 1M
[0.010s][info   ][gc     ] Using G1
[0.010s][info   ][gc,heap,coops] Heap address: 0x00000007ffe00000, size: 2 MB, Compressed Oops mode: Zero based, Oop shift amount: 3
[0.011s][info   ][gc,cds       ] Mark closed archive regions in map: [0x00000007fff00000, 0x00000007fff6eff8]
[0.011s][info   ][gc,cds       ] Mark open archive regions in map: [0x00000007ffe00000, 0x00000007ffe45ff8]
Error occurred during initialization of VM
GC triggered before VM initialization completed. Try increasing NewSize, current value 1331K.
```  



