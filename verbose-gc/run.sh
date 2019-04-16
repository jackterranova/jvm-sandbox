export JAVA_8=/Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home/
export JAVA_12=/Library/Java/JavaVirtualMachines/jdk-12.jdk/Contents/Home/

export JAVA_HOME=$JAVA_12
echo "Compiling and running with Java 12 ... \n"
javac HelloWorld.java

export JAVA_OPTS="-Xms1m -Xmx1m"
echo "OPTS $JAVA_OPTS:"
java -verbose:gc $JAVA_OPTS HelloWorld

export JAVA_OPTS="-Xms1m -Xmx2m"
echo "\nOPTS $JAVA_OPTS:"
java -verbose:gc $JAVA_OPTS HelloWorld

export JAVA_HOME=$JAVA_8
echo "Compiling and running with Java 8 ... \n"
javac HelloWorld.java

export JAVA_OPTS="-Xms1m -Xmx1m"
echo "OPTS $JAVA_OPTS:"
java -verbose:gc $JAVA_OPTS HelloWorld

export JAVA_OPTS="-Xms1m -Xmx2m"
echo "\nOPTS $JAVA_OPTS:"
java -verbose:gc $JAVA_OPTS HelloWorld
