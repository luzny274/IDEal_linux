cd ..

source ../project.settings
source ../Compilers/compilers.settings


echo "***Compiling for Ubuntu***"

mkdir -p ../Compiled/Ubuntu
$CPP -O2 -o ../Compiled/Ubuntu/$appName.out ${main} ${flags} ${ubuntuGLFlags} ${finalFlags}
