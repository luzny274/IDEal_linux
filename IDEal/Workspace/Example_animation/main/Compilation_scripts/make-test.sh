cd ..

source ../project.settings
source ../Compilers/compilers.settings

echo "Compiling..."
$CPP -o test ${main} ${flags} ${ubuntuGLFlags}

echo "Running..."
./test