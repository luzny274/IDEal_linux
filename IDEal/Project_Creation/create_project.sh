#!/bin/bash

currentFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Project name: "

read appName

echo "Choose start: Blank Project (0), Basic Project (1), Basic 3D Project (2)"

read typProj

while [ "$typProj" != "0" ] && [ "$typProj" != "1" ] && [ "$typProj" != "2" ]; do
	echo "Try again: "
	read typProj
done



create_android_project=../Project_Creation/android/create_android_project/create_android_project.sh
create_androidVR_project=../Project_Creation/android_vr/create_android_project/create_android_project.sh

mkdir $appName
mkdir $appName/main

ln -s $currentFolder/../Link/Compilers $appName/Compilers
ln -s $currentFolder/../Link/Bibliotekum_Ultimatum $appName/main/Bibliotekum_Ultimatum

mkdir $appName/main/${appName}_resources

mkdir $appName/main/Compilation_scripts
cp -a $currentFolder/../Project_Creation/Compilation_scripts/. $appName/main/Compilation_scripts/

$create_android_project $appName $currentFolder/$appName $currentFolder/../Project_Creation
$create_androidVR_project $appName $currentFolder/$appName $currentFolder/../Project_Creation

echo "package_1=com
package_2=mantegral
appName=$appName

main=\"main.cpp\"
finalFlags=\"-O2 -DFINAL\"
SDLFlags=\"-lSDL2 -DBU_SDL\"
glfwFlags=\"-lglfw3 -lm\"
flags=\"\$SDLFlags -DBU_APP_NAME=\\\"\$appName\\\" -Wall -std=c++17\"
windowsSDLFlags=\"-lmingw32 -lSDL2main -lSDL2\"
ubuntuGLFlags=\"-lGL -ldl -lXinerama -lXrandr -lXi -lXcursor -lX11 -lXxf86vm -lpthread -DBU_LINUX -DBU_DESKTOP\"
windowsGLFlags=\"-lopengl32 -lgdi32 -DBU_WINDOWS -DBU_DESKTOP\"

package_1=com
package_2=mantegral
appName=$appName

main=\"main.cpp\"
finalFlags=\"-DFINAL\"
flags=\"Bibliotekum_Ultimatum/Binaries/SDL/libSDL2.a -DBU_SDL -DBU_APP_NAME=\\\"\$appName\\\" -Wall -std=c++17\"
ubuntuGLFlags=\"-lGL -ldl -lXinerama -lXrandr -lXi -lXcursor -lX11 -lXxf86vm -lpthread -DBU_LINUX -DBU_DESKTOP\"

" >> $appName/project.settings


copyProjPath=$currentFolder/../Link/Bibliotekum_Ultimatum/IDEal/EmptyProjects
if [ "$typProj" == "0" ]; then
	copyProjPath=$copyProjPath/Blank
fi
if [ "$typProj" == "1" ]; then
	copyProjPath=$copyProjPath/Basic
fi
if [ "$typProj" == "2" ]; then
	copyProjPath=$copyProjPath/Basic3D
fi

cp -a $copyProjPath/. $appName/main/


