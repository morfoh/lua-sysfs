lua-sysfs
=======

LibSysfs bindings for Lua.

Installing
----------

### Install lua-sysfs:

	curl -O "__project_github_url__/raw/master/lua-sysfs-scm-0.rockspec"
	
	luarocks install lua-sysfs-scm-0.rockspec


To re-generating the bindings
-----------------------------

You will need to install LuaNativeObjects and set the CMake variable `USE_PRE_GENERATED_BINDINGS` to FALSE.
By default CMake will use the pre-generated bindings that are include in the project.

Build Dependencies
------------------

Optional dependency for re-generating Lua bindings from `*.nobj.lua` files:

* [LuaNativeObjects](https://github.com/Neopallium/LuaNativeObjects), this is the bindings generator used to convert the `*.nobj.lua` files into a native Lua module.

