#include <stdio.h>
#include <sys/xattr.h>
#include <ruby.h>
#include <string.h>
#include <stdbool.h>

#define TRUE 1
#define FALSE 0

bool is_exist_xattr(VALUE self, VALUE path) {
  long xattrListSize;
  xattrListSize = listxattr(StringValueCStr(path), NULL, 0, XATTR_NOFOLLOW);
  
  VALUE returnValue;
  if(xattrListSize > 0) {
    returnValue = TRUE;
  } else {
    returnValue = FALSE;
  }

  return returnValue;
}

void Init_file_util()
{
  VALUE module;
  module = rb_define_class("FileUtil", rb_cObject);
  rb_define_singleton_method(module, "xattr_exist?", RUBY_METHOD_FUNC(is_exist_xattr), 1);
  rb_define_const(module, "C_TRUE", TRUE);
  rb_define_const(module, "C_FALSE", FALSE);
}

