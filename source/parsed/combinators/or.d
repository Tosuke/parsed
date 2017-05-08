module parsed.combinators.or;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.conv : to;
import std.variant : Algebraic;

import std.meta : allSatisfy;
nothrow pure @safe @nogc OrParser!(Parsers) or(Parsers...)(Parsers parsers) if(allSatisfy!(isSomeParser, Parsers)) {
  return OrParser!(Parsers)(parsers);
}

unittest {
  import parsed.combinators.literal, parsed.combinators.any, parsed.combinators.many;
  auto parser = or(literal("hoge"), literal("piyo"), any);
  parser(parseInput("hoge")); 
}


private struct OrParser(Parsers...) {
  import std.meta : staticMap, NoDuplicates, ApplyRight;
  import std.traits : CommonType;

  private Parsers parsers;

  nothrow pure @safe @nogc this(Parsers parsers) {
    this.parsers = parsers;
  }

  auto opCall(S)(ParseInput!S input) {
    alias F = ApplyRight!(ParserType, S);
    alias ParserTypes = NoDuplicates!(staticMap!(F, Parsers));

    static if(is(CommonType!(ParserTypes) == void)) {
      alias RT = Algebraic!(ParserTypes);
      RT result;
    } else {
      alias RT = CommonType!(ParserTypes);
      RT result;
    }

    foreach(parser; parsers) {
      auto r = parser(input);
      if(r.success) {
        result = r.result;
        return parseSuccess!RT(result, r.matchedLength);
      }
    }

    return parseFailure!RT(input, "expected one of parsers matched, but no parser matched");
  }
}

@system unittest {
  import parsed.combinators.literal : literal;
  import parsed.combinators.any: any;

  auto parser = or(literal("hoge"), any);
  assert(parse!parser("hoge").result.get!string == "hoge");
  assert(parse!parser("a").result.get!char == 'a');
}