module parsed.combinators.any;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeString, Unqual;
import std.range.primitives : ElementEncodingType;
import std.array;


enum any = AnyParser.init;

private struct AnyParser {
  pure nothrow @safe @nogc ParseResult!(Unqual!(ElementEncodingType!S)) opCall(S)(ParseInput!S input) {
    alias C = Unqual!(ElementEncodingType!S);
    if(!input.empty) {
      return parseSuccess(cast()input[0], 1);
    } else {
      return parseFailure!C(input, "end of source");
    }
  }
}

///
pure @safe unittest {
  static assert(isParser!(any, string));
  static assert(isParser!(any, wstring));
  static assert(isParser!(any, dstring)); 

  assert(parse!any("").error.msg == "end of source");
  assert(parse!any("aaa") == 'a');
  assert(parse!any("aaa").matchedLength == 1);  

  assert(parse!any("鮨"w) == '鮨');
  assert(parse!any("🍣"d) == '🍣');
}