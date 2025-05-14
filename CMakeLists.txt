#=============================================================================
# Syntax Social Application - CMake Build Configuration
#=============================================================================
# Project    : Syntax Social Media Application
# Author     : Syed Al Rizvi (sanecodeguy)
# Date       : 2023-11-15
# Repository : https://github.com/sanecodeguy/SyntaxSocialApp
# Description: Modern social media application with Qt6/QML interface
#=============================================================================

cmake_minimum_required(VERSION 3.16)

#-----------------------------------------------------------------------------
# Project Configuration
#-----------------------------------------------------------------------------
project(SyntaxSocialApp
    VERSION 1.0.0
    DESCRIPTION "Modern social media application"
    LANGUAGES CXX
)

#-----------------------------------------------------------------------------
# CMake Configuration
#-----------------------------------------------------------------------------
set(CMAKE_AUTOMOC ON)      # Enable automatic meta-object compilation
set(CMAKE_AUTORCC ON)     # Enable automatic resource compilation
set(CMAKE_AUTOUIC ON)     # Enable automatic UI compilation
set(CMAKE_CXX_STANDARD 17) # Require C++17 standard
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#-----------------------------------------------------------------------------
# Output Formatting Configuration
#-----------------------------------------------------------------------------
if(NOT CMAKE_CONFIGURATION_TYPES)
    if(CMAKE_BUILD_TYPE STREQUAL "")
        message(STATUS "Setting build type to 'Release' as none was specified")
        set(CMAKE_BUILD_TYPE Release)
    endif()
    
    message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
    message(STATUS "Output directory: ${CMAKE_BINARY_DIR}")
endif()

#-----------------------------------------------------------------------------
# Qt6 Dependencies
#-----------------------------------------------------------------------------
find_package(Qt6 REQUIRED COMPONENTS 
    Core 
    Quick 
    QuickControls2
)

message(STATUS "Found Qt6 version: ${Qt6_VERSION}")
message(STATUS "Qt6 modules: Core, Quick, QuickControls2")

#-----------------------------------------------------------------------------
# Application Executable
#-----------------------------------------------------------------------------
message(STATUS "Configuring Syntax application executable...")

add_executable(Syntax
    core/main.cpp
    core/Page.cpp
    core/Post.cpp
    core/PageLoader.cpp
    core/User.cpp
    core/Syntax.cpp
    core/Date.cpp
    core/Comment.cpp
)

message(STATUS "Source files added to Syntax executable")

#-----------------------------------------------------------------------------
# QML Configuration
#-----------------------------------------------------------------------------
set(QML_IMPORT_PATH 
    ${Qt6_DIR}/../../qml
    ${CMAKE_CURRENT_SOURCE_DIR}/qml
)

message(STATUS "QML import paths configured: ${QML_IMPORT_PATH}")

#-----------------------------------------------------------------------------
# Resource Management
#-----------------------------------------------------------------------------
message(STATUS "Configuring application resources...")

# Ensure build directory structure exists for images
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/qml/images/posts)

# Copy post images to build directory
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/qml/images/posts/
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/qml/images/posts)

message(STATUS "Post images copied to build directory")

# Main QML files
qt_add_resources(Syntax "qml_files"
    PREFIX "/"
    FILES
        qml/main.qml
        qml/screens/AuthScreen.qml
        qml/screens/HomeScreen.qml
        qml/screens/Discover.qml
        qml/screens/Friends.qml
        qml/screens/Profile.qml
        qml/ExpandableBottomBar/NavigationBar.qml
)

# Post images resource
qt_add_resources(Syntax "post_images"
    PREFIX "/"
    BASE ${CMAKE_CURRENT_BINARY_DIR}
    FILES
        qml/images/posts/01.jpg
        qml/images/posts/02.jpg
        qml/images/posts/03.jpg
        qml/images/posts/04.jpg
        qml/images/posts/a1.jpg
        qml/images/posts/a2.jpg
        qml/images/posts/a3.jpg
        qml/images/posts/a4.jpg
        qml/images/posts/f1.jpg
        qml/images/posts/f3.jpg
        qml/images/posts/f2.jpg
        qml/images/posts/f4.jpg
        qml/images/posts/s1.jpg
        qml/images/posts/s2.jpg
        qml/images/posts/s3.jpg
        qml/images/posts/r1.jpg
        qml/images/posts/r2.jpg
        qml/images/posts/r3.jpg
        qml/images/posts/r4.jpg
)

# JSON file resource
qt_add_resources(Syntax "json_data"
    PREFIX "/"
    FILES
        assets/data/AllPages.json
        assets/data/liked_pages.json
)

# Tab icons
qt_add_resources(Syntax "tab_icons"
    PREFIX "/icons"
    FILES
        qml/screens/icons/home.png
        qml/screens/icons/search.png
        qml/screens/icons/add.png
        qml/screens/icons/heart.png
        qml/screens/icons/profile.png
)

message(STATUS "All resources configured successfully")

#-----------------------------------------------------------------------------
# Linking and Final Configuration
#-----------------------------------------------------------------------------
message(STATUS "Linking Qt6 libraries to Syntax executable...")

target_link_libraries(Syntax PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
)

qt_import_qml_plugins(Syntax)

message(STATUS "Syntax application configuration complete!")
message(STATUS "------------------------------------------------")
message(STATUS "Project: Syntax Social Media Application")
message(STATUS "Author: Syed Al Rizvi (sanecodeguy)")
message(STATUS "GitHub: https://github.com/sanecodeguy/SyntaxSocialApp")
message(STATUS "Build System: CMake ${CMAKE_VERSION}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "------------------------------------------------")