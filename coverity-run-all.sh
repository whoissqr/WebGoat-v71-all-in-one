#!/bin/sh

# remove any previous intermediat results and start refresh
rm -rf idir 2> /dev/null

cd WebGoat-Lessons
cov-build --dir ../idir --return-emit-failures mvn clean package -DskipTests

cd ..
# install lessons to server
cp WebGoat-Lessons/target/plugins/*.jar WebGoat-7.1/webgoat-container/src/main/webapp/plugin_lessons/

# compile the server
cd WebGoat-7.1

# analyze everything
cov-build --dir ../idir --return-emit-failures mvn clean compile install -DskipTests

cov-emit-java --dir ../idir --war webgoat-container/target/webgoat-container-7.1.war

cov-import-scm --scm git --dir ../idir  --log ../scm-log.txt

cov-analyze --dir ../idir --all -disable-fb --webapp-security

cov-commit-defects --dir ../idir --host localhost --stream WebGoat-71 --auth-key-file ~/cc.key

