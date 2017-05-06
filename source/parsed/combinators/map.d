module parsed.combinators.map;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;


template map(fun...) {
  import std.functional : unaryFun, adjoin;
  import std.meta : staticMap;

  static if(fun.length == 1) {
    alias f = unaryFun!fun;
  } else {
    alias f = adjoin!(staticMap!(unaryFun, fun));
  }

  nothrow pure @safe @nogc auto map(Parser)(Parser parser) if(isSomeParser!Parser) {
    return MapParser!(f, Parser)(parser);
  }
}


private struct MapParser(alias fun, Parser) if(isSomeParser!Parser) {
  private Parser parser;

  nothrow pure @safe @nogc this(Parser parser) {
    this.parser = parser;
  }

  auto opCall(S)(ParseInput!S input) if(isParser!(Parser, S)) {
    alias RT = typeof({
      ParserType!(Parser, S) a = void;
      return fun(a);
    }());

    auto result = parser(input);
    if(result.success) {
      return parseSuccess!RT(fun(result.result), result.matchedLength);
    } else {
      return parseFailure!RT(input, result.error.msg);
    }
  }
}


@safe pure unittest {
  import parsed.combinators.range : range;
  import parsed.combinators.many : many;
  import std.conv : to;

  enum parser = range('0', '9').many(1).map!(a => a.to!int);
  assert(parse!parser("114514") == 114514);
  assert(parse!parser("114514").matchedLength == 6);
  assert(parse!parser("").error.msg == "expect at least 1 matches, but got 0 matches");
}