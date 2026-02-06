// -*- compile-command: "g++ -I/c/xcas/include -DWIN32 -DHAVE_CONFIG_H -DIN_GIAC -DDOUBLEVAL -DUSE_OPENGL32 -DGIAC_GENERIC_CONSTANTS -g pgcd.cc giac.dll -lpthread -lintl -mwindows -lole32 -luuid -lcomctl32 -lwsock32" -*-
// This program must be compiled with cygwin
// Then issue the compile-command above (or run Tools->compile under emacs)
// The executable is a.exe, use -o filename for another executable name
// Some help is available in doc/en/giac_us.html
#include <giac/giac.h>

using namespace std;
using namespace giac;

gen pgcd(const gen &a0,const gen & b0){
  gen a,b,q,r;
  a=a0;
  b=b0;
  for (;b!=0;){
    r=irem(a,b,q);
    a=b;
    b=r;
  }
  return a;
}

int main(){
  gen a(15),b(25);
  a=pgcd(a,b);
  if (debug_infolevel>1)
    a.dbgprint();
  cout << a << endl;
  context ct;
  cout << "Enter an expression "<< endl;
  string sa;
  cin >> sa;
  a=gen(sa,&ct);
  cout << a << endl;
  a=eval(a,1,&ct);
  cout << _factor(a,&ct) << endl;
  vecteur l=lidnt(a);
  if (!l.empty())
    a=derive(a,l.front(),&ct);
  cout << a << endl;
  return 0;
}
