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

### Java Instrumentation Agent

It not a simple matter to get Java to tell you how much memory your objects are using.  

Using an instrumentation agent like in `java.land.instrument`, we can determine object memory size.

_Steps_

1. Create an instrumentation object
2. Compile the object in to its own jar with a special manifest file
3. Use the agent in a client program, specifying the agent on the command line of the client through the `–javaagent` option

### In the previous branch (02-gc-log-details)

** Summary **

`GC (Allocation Failure)`: indicates a `minor` or `partial` GC occurred.
`512K->376K(1536K)`: in a gc log shows how much memory was cleared during a gc (including the total heap size) 

### On this branch

* Tweak the example program and look more closely at memory usage and how gc's are triggered.
* Specifically we look at how to calculate how much space an object uses.

__Questions from previous branch__
* We specify `Xmx1m` yet we see the total heap space to be 1.5M.  Why is this?
* What exactly is our test program doing?  
* How much memory is being consumed in the loop? 
* Why is GC happening at 500k/800k points? 
      
### Results of this branch


### Questions   


### Raw output of this branch