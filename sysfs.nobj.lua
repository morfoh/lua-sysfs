-- make generated variable nicer
set_variable_format "%s"

c_module "sysfs" {

-- enable FFI bindings support.
luajit_ffi = true,

-- load SYSFS shared library.
ffi_load"sysfs",

sys_include "sysfs/libsysfs.h",

subfiles {
"src/sysfs.nobj.lua",
},
}

