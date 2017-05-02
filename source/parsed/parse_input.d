module parsed.parse_input;

import std.traits : isSomeString;

nothrow @safe @nogc ParseInput!S parseInput(S)(S source, size_t begin = 0) if(isSomeString!S) {
  return ParseInput!S(source, begin);
}

struct ParseInput(S) if(isSomeString!S) {
public:
  alias input this;
  @property nothrow @safe @nogc {
    S input() const {
      return this.source[this.begin..$];
    }
    
    S source() const {
      return source_;
    }

    size_t begin() const {
      return begin_;
    }
  }
package:
  @property nothrow @safe @nogc this(S _source, size_t _begin) {
    this.source_ = _source;
    this.begin_ = _begin;
  }
private:
  S source_;
  size_t begin_;
}