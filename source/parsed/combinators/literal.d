module parsed.combinators.literal;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeString, isSomeChar, Unqual;
import std.range.primitives : ElementEncodingType;
import std.array;
import std.conv : to;

nothrow pure @safe @nogc LiteralParser!S literal(S)(S pattern) if(isSomeString!S) {
  return LiteralParser!S(pattern);
}

private struct LiteralParser(Pattern) if(isSomeString!Pattern) {
  nothrow pure @safe @nogc this(Pattern p) {
    pattern = p;
  }
  private Pattern pattern;

  pure @safe ParseResult!S opCall(S)(ParseInput!S input) {
    auto p = pattern.to!S;
    if(input.length >= p.length && input[0..p.length] == p) {
      return parseSuccess(p, p.length);
    } else {
      return parseFailure!S(input, `expect "` ~ pattern.to!string ~ `"`);
    }
  }
}

@safe pure unittest {
  static assert(isParser!(literal("a"), string));
  static assert(isParser!(literal("a"), wstring));
  static assert(isParser!(literal("a"), dstring));
  
  static assert(isParser!(literal("鮨"w), wstring));
  static assert(isParser!(literal("鮨"w), dstring));
  
  static assert(isParser!(literal("🍣"d), dstring));

  assert(parse!(literal("hoge"))("hogehogepiyopiyo") == "hoge");
  assert(parse!(literal("hoge"))("hogehogepiyopiyo").matchedLength == 4);
  assert(parse!(literal("hoge"))("piyopiyohogehoge").error.msg == `expect "hoge"`);
}