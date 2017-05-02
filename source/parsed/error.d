module parsed.error;


struct ParseError {
  string msg;
  size_t pos;
}


package(parsed) pure nothrow @safe ParseException parseException(ParseError err, string file = __FILE__, size_t line = __LINE__) {
  import std.conv : to;
  return new ParseException("(" ~ err.pos.to!string ~ ") " ~ err.msg, file, line, null);
}


class ParseException : Exception {
  package pure nothrow @safe @nogc this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super(msg, file, line, next);
  }
}