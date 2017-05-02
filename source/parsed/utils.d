module parsed.utils;

package(parsed):

import std.utf;

pure nothrow @safe char toChar(C)(C c) {
  static if(is(C == char)) {
    return c;
  } else {
    static assert(0, "cannnot implicitly convert char to " ~ C.stringof);
  }
}


pure nothrow @safe wchar toWchar(C)(C c) {
  static if(is(C == char)) {
    return [c].byWchar.front;
  } else static if(is(C == wchar)){
    return c;
  } else {
    static assert(0, "cannnot implicitly convert char to " ~ C.stringof);
  }
}


pure nothrow @safe dchar toDchar(C)(C c) {
  static if(is(C == char) || is(C == wchar)) {
    return [c].byDchar.front;
  } else static if(is(C == dchar)){
    return c;
  } else {
    static assert(0, "cannnot implicitly convert char to " ~ C.stringof);
  }
}

