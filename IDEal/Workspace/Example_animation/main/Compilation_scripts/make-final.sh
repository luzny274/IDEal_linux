cd ..

source ../project.settings
source ../Compilers/compilers.settings


echo "***Compiling for Ubuntu***"

mkdir -p ../Compiled/Ubuntu
$CPP -O2 -o ../Compiled/Ubuntu/$appName.out ${main} ${flags} ${ubuntuGLFlags} ${finalFlags}

rm -rf ../Compiled/Ubuntu/${appName}_resources
cp -a ${appName}_resources ../Compiled/Ubuntu/${appName}_resources

cd Compilation_scripts
./make-final-android.sh
./make-final-androidVR.sh