#!/bin/bash

set -e #exit if any command returns a non-zero exit status

#Checking for the required packages
command -v qmake6 >/dev/null || {
  echo "ERROR: qmake6 missing"
  exit 1
}
command -v cmake >/dev/null || {
  echo "ERROR: cmake missing"
  exit 1
}
command -v g++ >/dev/null || {
  echo "ERROR: g++ missing"
  exit 1
}

qmake6 --version
cmake --version
g++ --version

echo "Environment OK"

# Creatinge the files and folders
read -p "Enter the project name: " projectname
mkdir -p $projectname
cd $projectname
mkdir -p build
mkdir -p src
touch src/main.cpp
touch CMakeLists.txt

#writing the CMakeLists.txt file
cat <<EOL >CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project($projectname)

# This enables the fix for your LSP warnings
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find the Qt6 packages you installed
find_package(Qt6 REQUIRED COMPONENTS Widgets)

set(CMAKE_CXX_STANDARD 17)

# Standard Qt settings
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

add_executable($projectname src/main.cpp)

# Link the libraries
target_link_libraries($projectname PRIVATE Qt6::Widgets)
EOL

echo "CmakeLists.txt created"

# 1. Configure and generate the LSP database
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json .
echo "CMake configuration done, compile_commands.json linked"

#writing the main.cpp file
cat <<EOL >src/main.cpp
#include <QApplication>
#include <QWidget>
int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QWidget window;
    window.resize(250, 150);
    window.setWindowTitle("Hello Qt6");
    window.show();
    return app.exec();
}
EOL

echo "Automation script completed successfully."
echo "You can now build your project using:\n
'cmake --build build' and run it with './build/$projectname'."
