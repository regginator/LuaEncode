rm -r -f ./build # If old `./build`, remove
mkdir ./build
cp ./LICENSE.txt ./build/LICENSE.txt
echo "Copied ./LICENSE.txt to ./build/LICENSE.txt"
cp ./src/LuaEncode.lua ./build/LuaEncode.lua
echo "Copied ./src/LuaEncode.lua to ./build/LuaEncode.lua"
rojo build -o ./build/LuaEncode.rbxm
rojo build -o ./build/LuaEncode.rbxmx
