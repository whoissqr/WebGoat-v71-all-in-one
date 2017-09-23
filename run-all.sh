#!/bin/sh
# RUN the following from cygwin
# there are 2 parts needs to compiled -- the lessons and webgoat-7.1
# the lessons will be built first and output to target\plugins\ folder
# we need to copy those .jar files to webgoat-7.1 before compiling webgoat-7.1

# add maven and 7z binary to path

# remove any previous intermediat results and start refresh
rm -rf idir 2> /dev/null
rm -rf WebGoat-7.1 2> /dev/null
rm 7.1.zip 2> /dev/null
rm -rf WebGoat-Lessons 2> /dev/null

# checkout the lessons
git clone https://github.com/WebGoat/WebGoat-Lessons.git
# checkout the classic webgoat-7.1
wget https://github.com/WebGoat/WebGoat/archive/7.1.zip
# extract the zip to WebGoat-7.1
7z x 7.1.zip -y

cd WebGoat-Lessons
cov-build --dir ../idir --return-emit-failures mvn clean package -DskipTests

cd ..
# install lessons to server
cp WebGoat-Lessons\target\plugins\*.jar WebGoat-7.1\webgoat-container\src\main\webapp\plugin_lessons

# compile the server
cd WebGoat-7.1

# analyze everything
cov-build --dir ../idir --return-emit-failures mvn clean compile install -DskipTests

cov-emit-java --dir ../idir --war webgoat-container/target/webgoat-container-7.1.war

cov-import-scm --scm git --dir ../idir  --log ../scm-log.txt

cov-analyze --dir ../idir --all -disable-fb --webapp-security

cov-commit-defects --dir ../idir --host localhost --stream WebGoat-71 --auth-key-file ~/cc.key

