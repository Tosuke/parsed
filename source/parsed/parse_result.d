module parsed.parse_result;
import parsed.error;
import parsed.parse_input;
import std.traits : Unqual;

pure nothrow @safe @nogc ParseResult!T parseSuccess(T)(T value, size_t matchedLength) {
  return ParseResult!T(value, matchedLength);
}

pure nothrow @safe @nogc ParseResult!T parseFailure(T, S)(ParseInput!S input, string msg) {
  ParseError err;
  err.msg = msg;
  err.pos = input.begin;
  return ParseResult!T(err);
}

struct ParseResult(T) if(!(is(T == void) || is(T == ParseError))) {
public:
  @property pure @safe {
    nothrow @nogc bool success() const {
      return this.success_;
    }

    T result() {
      if(this.success) {
        return this.forceValue;
      } else {
        throw parseException(this.forceError);
      }
    }

    ParseError error() {
      if(!this.success) {
        return this.forceError;
      } else {
        throw new Exception("error is not occured");
      }
    }

    nothrow @nogc size_t matchedLength() const {
      return this.matchedLength_;
    }
  }

  alias result this;
package:
  /// success
  pure nothrow @trusted @nogc this(T value, size_t matchedLength) {
    this.success_ = true;
    this.result_.v = value;
    this.matchedLength_ = matchedLength;
  }

  /// failure
  pure nothrow @trusted @nogc this(ParseError err) {
    this.success_ = false;
    this.result_.e = err;
    this.matchedLength_ = 0;
  }
private:
  bool success_;
  union U {
    Unqual!T v;
    ParseError e;
  }
  U result_;

  size_t matchedLength_;

  @property nothrow @safe @nogc {
    pure T forceValue() {
      static if(is(Unqual!T == T)) {
        return (() @trusted => result_.v)();
      } else {
        return (() @trusted => cast(T)result_.v)();
      }
    }

    pure ParseError forceError() {
      return (() @trusted => result_.e)();
    }
  } 
}