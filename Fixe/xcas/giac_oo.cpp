// -*- compile-command: "g++ -Isrc -c giac_oo.cpp" -*-
// dlltool --export-all --output-def giac_oo.def giac_oo.o
// dllwrap giac_oo.o --dllname giac_oo.dll --def giac_oo.def /bin/giac.dll -lstdc++ -lpthread -lintl -mwindows -lole32 -luuid -lcomctl32 -lwsock32
// lib /machine:i386 /def:giac_oo.def
#include "giac/giac.h"

extern "C" const char * parse_eval(const char * ch,int level,void * contextptr){
  static std::string s;
  giac::context * cptr = (giac::context *)contextptr;
  signal(SIGINT,giac::ctrl_c_signal_handler);
  giac::logptr(&std::cout,0);
  giac::child_id=1;
  giac::gen g(ch,cptr);
  g=protecteval(g,level,cptr);
  s=g.print(cptr);
  return s.c_str();
}

