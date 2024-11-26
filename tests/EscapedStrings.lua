--!nocheck
local LuaEncode = string.sub(_VERSION, 1, 4) == "Luau" and require("../src/LuaEncode") or require("src/LuaEncode")

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
    "\29",
    "hello, \"world\"! \\0 == \0, \\b == \b, \\n == \n",
    "😀 😃 😄 😁 😆 😅 😂 🤣 🥲 🥹 ☺️ 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🥸 🤩 🥳 😏 😒"
}

print(LuaEncode(Table, {
    Prettify = true,
}))
