cd ..

source ../project.settings

echo "***Compiling for android***"

cd ../Android_$appName
./build.sh
./test.sh