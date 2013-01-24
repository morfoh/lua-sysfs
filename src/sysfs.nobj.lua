-- Copyright (c) 2013 by Christian Wiese <chris@opensde.org>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

--
-- typedefs
--
local typedefs = [[
typedef struct sysfs_attribute attribute;
typedef struct sysfs_device device;
typedef struct sysfs_class class;
typedef struct sysfs_class_device class_device;
typedef struct sysfs_bus bus;
typedef struct dlist dlist;
]]
c_source "typedefs" (typedefs)
-- pass extra C type info to FFI.
ffi_cdef (typedefs)

--
-- Functions
--

c_function "get_mnt_path" {
	var_out { "char *", "mnt_path" },
	c_source[[
  char path[PATH_MAX];

  if (sysfs_get_mnt_path(path, PATH_MAX)) {
	lua_pushnil(L);
	return 1;
  } else {
	${mnt_path} = path;
  }
]],
}

--
-- dlist
--

object "dlist" {
}


--
-- attribute
--

object "attribute" {

	-- open
	constructor "open" {
		c_call "attribute *" "sysfs_open_attribute" {
						"const char *", "path",
		}
	},

	-- close
	destructor "close" {
		c_method_call "void" "sysfs_close_attribute" {}
	},
}


--
-- device
--

object "device" {
	c_source {
	[[

/* internal sysfs device iterator function */
static int lua_sysfs_device_iterator(lua_State *L) {
	struct dlist *list = *(struct dlist **) lua_touserdata(L, lua_upvalueindex(1));
	struct sysfs_device *obj;

	/* TODO: clarify the flag types
	 * OBJ_UDATA_FLAG_OWN segfaults here with lua and luajit
	 * OBJ_UDATA_FLAG_LOOKUP works with lua but segfaults with luajit
	 */
	int obj_flags = 0;

	if ((obj = dlist_next(list)) != NULL) {
		obj_type_device_push(L, obj, obj_flags);
		return 1;
	} else {
		return 0;
	}
}
	]]
},

	-- open
	constructor "open" {
		c_call "device *" "sysfs_open_device" {
						"const char *", "bus",
						"const char *", "bus_id"
		}
	},

	-- close
	destructor "close" {
		c_method_call "void" "sysfs_close_device" {}
	},

	-- open tree
	constructor "open_tree" {
		c_call "device *" "sysfs_open_device_tree" {
						"const char *", "path",
		}
	},

	-- close tree
	destructor "close_tree" {
		c_method_call "void" "sysfs_close_device_tree" {}
	},

	-- open path
	constructor "open_path" {
		c_call "device *" "sysfs_open_device_path" {
						"const char *", "path",
		}
	},

	-- get parent device
	method "get_parent" {
		c_method_call "device *" "sysfs_get_device_parent" {}
	},

	-- get bus
	method "get_bus" {
		c_method_call "int" "sysfs_get_device_bus" {}
	},
}


--
-- class device
--

object "class_device" {

	-- open
	constructor "open" {
		c_call "class_device *" "sysfs_open_class_device" {
						"const char *", "classname",
						"const char *", "name"
		}
	},

	-- open path
	constructor "open_path" {
		c_call "class_device *" "sysfs_open_class_device_path" {
						"const char *", "path"
		}
	},

	-- get class device parent
	constructor "get_parent" {
		c_call "class_device *" "sysfs_get_classdev_parent" {
						"class_device *", "clsdev"
		}
	},

	-- get class device
	constructor "get" {
		c_call "class_device *" "sysfs_get_class_device" {
						"class *", "class",
						"const char *", "name"
		}
	},

	-- close
	destructor "close" {
		c_method_call "void" "sysfs_close_class_device" {}
	},

	-- get name
	method "get_name" {
		c_source[[
  lua_pushstring(L, ${this}->name);
  return 1;
		]]
	},

	-- get path
	method "get_path" {
		c_source[[
  lua_pushstring(L, ${this}->path);
  return 1;
		]]
	},

	-- get classname
	method "get_classname" {
		c_source[[
  lua_pushstring(L, ${this}->classname);
  return 1;
		]]
	},

	-- get attribute
	method "get_attribute" {
		c_method_call "attribute *" "sysfs_get_classdev_attr" {
						"const char *", "name"
		}
	},

	-- get attributes
	method "get_attributes" {
		c_method_call "dlist *" "sysfs_get_classdev_attributes" {}
	},
}


--
-- sysfs class
--


object "class" {

	-- open
	constructor "open" {
		c_call "class *" "sysfs_open_class" { "const char *", "name" }
	},

	-- close
	destructor "close" {
		c_method_call "void" "sysfs_close_class" {}
	},

	-- get a list of devices
	method "get_devices" {
		c_method_call "dlist *" "sysfs_get_class_devices" {}
	},

c_source {
[[

static int class_device_iter (lua_State *L) {
	struct dlist *clsdevlist = *(struct dlist **) lua_touserdata(L, lua_upvalueindex(1));
	struct sysfs_class_device *obj;

	/* TODO: clarify the flag types
	 * OBJ_UDATA_FLAG_OWN segfaults here with lua and luajit
	 * OBJ_UDATA_FLAG_LOOKUP works with lua but segfaults with luajit
	 */
	int obj_flags = 0;

	if ((obj = dlist_next(clsdevlist)) != NULL) {
		obj_type_class_device_push(L, obj, obj_flags);
		return 1;
	} else {
		return 0;
	}
}
]]
},

	-- get a list of devices
	method "for_each_device" {
		c_source[[
  struct dlist **clsdevlist = (struct dlist **) lua_newuserdata(L, sizeof(struct dlist *));

  *clsdevlist = sysfs_get_class_devices(${this});

  if (clsdevlist) {
		dlist_start(*clsdevlist);
		lua_pushcclosure(L, class_device_iter, 1);
		return 1;
  } 
		]],
	},
}


--
-- sysfs bus
--
object "bus" {
	-- open bus
	constructor "open" {
		c_call "bus *" "sysfs_open_bus" { "const char *", "name" }
	},
	-- close bus
	destructor "close" {
		c_method_call "void" "sysfs_close_bus" {}
	},
	-- sysfs device iterator
	method "for_each_device" {
		c_source[[
  struct dlist **list = (struct dlist **) lua_newuserdata(L, sizeof(struct dlist *));

  *list = sysfs_get_bus_devices(${this});

  if (list) {
		dlist_start(*list);
		lua_pushcclosure(L, lua_sysfs_device_iterator, 1);
		return 1;
  }
		]],
	},
}
