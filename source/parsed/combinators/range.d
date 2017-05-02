module parsed.combinators.range;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeString, isSomeChar, Unqual;
import std.range.primitives : ElementEncodingType;
import std.array;
import std.conv : to;

public nothrow pure @safe @nogc RangeParser!(Begin, End) range(Begin, End)(Begin begin, End end) if(isSomeChar!Begin && isSomeChar!End) {
  return RangeParser!(Begin, End)(begin, end);
}

private struct RangeParser(Begin, End) if(isSomeChar!Begin && isSomeChar!End) {
  nothrow pure @safe @nogc this(Begin begin, End end) {
    begin_ = begin;
    end_ = end;
  }
  private Begin begin_;
  private End end_;
  pure @safe ParseResult!(Unqual!(ElementEncodingType!S)) opCall(S)(ParseInput!S input) {
    alias C = Unqual!(ElementEncodingType!S);

    if(input.empty) {
      return parseFailure!C(input, "end of source");
    }

    auto begin = begin_.to!C;
    auto end = end_.to!C;

    if(begin > end) {
      import std.algorithm.mutation : swap;
      swap(begin, end);
    }

    if(begin <= input[0] && input[0] <= end) {
      return parseSuccess(cast()input[0], 1);
    } else {
      return parseFailure!C(input,
        "expect '" ~ begin.to!string ~ "'~'" ~ end.to!string ~ "', but got '" ~ input[0].to!string ~ "'");
    }
  }
}

@safe pure unittest {
  // char
  static assert(isParser!(range('a', 'z'), string));
  static assert(isParser!(range('a', 'z'), wstring));
  static assert(isParser!(range('a', 'z'), dstring));

  static assert(isParser!(range('z', 'a'), string));
  static assert(isParser!(range('z', 'a'), wstring));
  static assert(isParser!(range('z', 'a'), dstring));

  // wchar
  static assert(isParser!(range('あ', 'お'), wstring));
  static assert(isParser!(range('あ', 'お'), dstring));

  // dchar
  static assert(isParser!(range('👨', '👩'), dstring));

  assert(parse!(range('a', 'z'))("").error.msg == "end of source");
  assert(parse!(range('a', 'z'))("0").error.msg == "expect 'a'~'z', but got '0'");
  assert(parse!(range('z', 'a'))("0").error.msg == "expect 'a'~'z', but got '0'");
  
  assert(parse!(range('a', 'z'))("a") == 'a');
  assert(parse!(range('a', 'z'))("z") == 'z');
  assert(parse!(range('a', 'z'))("j") == 'j');
  assert(parse!(range('a', 'z'))("j").matchedLength == 1);

  assert(parse!(range('z', 'a'))("a") == 'a');
  assert(parse!(range('z', 'a'))("z") == 'z');
  assert(parse!(range('z', 'a'))("j") == 'j');
  assert(parse!(range('z', 'a'))("j").matchedLength == 1);
}