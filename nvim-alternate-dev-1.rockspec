rockspec_format = "3.0"
package = "nvim-alternate"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/Dkendal/nvim-plugin.git"
}
description = {
   summary = "",
   detailed = "",
   homepage = "https://github.com/dkendal/nvim-plugin",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {},
   copy_directories = {}
}
dependencies = {
}
test_dependencies = {
   "lua == 5.1",
   "busted ~> 2.2.0",
   "luassert ~> 1.9.0",
   "luacov ~> 0.15.0",
   "luacov-multiple ~> 0.6"
}
test = {
   command = "busted",
   flags = {
      "--shuffle",
      "--coverage",
      "--defer-print"
   }
}
