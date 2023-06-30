local LuaEncode = require("src/LuaEncode")

local Table = {
    "\"",
    "\\",
    "\a",
    "\b",
    "\t",
    "\n",
    "\v",
    "\f",
    "\r",
    "\0\1\2\3\4\5\6\7\8\9\10\11\12\13",
    "\127\175",
    "\29", -- 0x1D real..
    "hello, \"world\"! i love null bytes like \0, and characters like \b really screw with the console.. \n\n\nnewline moment??",
    "what is \"roblox\"?\n\nyep",
    "let's be frienz! 😀 😃 😄 😁 😆 😅 😂 🤣 🥲 🥹 ☺️ 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🥸 🤩 🥳 😏 😒"
}

print(LuaEncode(Table, {
    Prettify = true,
}))
