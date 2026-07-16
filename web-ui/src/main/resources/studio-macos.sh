#!/bin/sh

STUDIO_PATH="`dirname \"$0\"`"
DOT_STUDIO="$HOME/.studio"

# Detect architecture
ARCH=$(uname -m)

# Make sure the .studio subdirectories exist
if [ ! -d $DOT_STUDIO/agent ]; then mkdir -p $DOT_STUDIO/agent; fi
if [ ! -d $DOT_STUDIO/db ]; then mkdir -p $DOT_STUDIO/db; fi
if [ ! -d $DOT_STUDIO/library ]; then mkdir -p $DOT_STUDIO/library; fi

# Copy agent and metadata JARs
cp $STUDIO_PATH/agent/studio-agent-${project.version}-jar-with-dependencies.jar $DOT_STUDIO/agent/studio-agent.jar
cp $STUDIO_PATH/agent/studio-metadata-${project.version}-jar-with-dependencies.jar $DOT_STUDIO/agent/studio-metadata.jar

# For ARM64 (Apple Silicon), disable USB driver as workaround for usb4java 1.3.0 not supporting darwin-aarch64
# The application will run without USB device support
if [ "$ARCH" = "arm64" ]; then
    echo "Running on ARM64 (Apple Silicon) - USB driver disabled (not supported by usb4java 1.3.0)"
    java -Dvertx.disableDnsResolver=true -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager -Dvertx.logger-delegate-factory-class-name=io.vertx.core.logging.Log4j2LogDelegateFactory -Dfile.encoding=UTF-8 -Dstudio.usb.disabled=true -cp $STUDIO_PATH/${project.build.finalName}.jar:$STUDIO_PATH/lib/*:. io.vertx.core.Launcher run ${vertx.main.verticle}
else
    java -Dvertx.disableDnsResolver=true -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager -Dvertx.logger-delegate-factory-class-name=io.vertx.core.logging.Log4j2LogDelegateFactory -Dfile.encoding=UTF-8 -cp $STUDIO_PATH/${project.build.finalName}.jar:$STUDIO_PATH/lib/*:. io.vertx.core.Launcher run ${vertx.main.verticle}
fi
