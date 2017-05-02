module parsed.combinators.many;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeChar, isSomeString;
import std.conv : to;
import std.array : appender;


nothrow pure @safe @nogc auto many(Parser)(Parser parser, size_t atLeast = 0) if(isSomeParser!Parser) {
  return ManyParser!Parser(parser, atLeast);
}


private struct ManyParser(Parser) if(isSomeParser!Parser) {
  private size_t atLeast;
  private Parser parser;
  
  nothrow pure @safe @nogc this(Parser parser, size_t atLeast) {
    this.parser = parser;
    this.atLeast = atLeast;
  }

  auto opCall(S)(ParseInput!S input) if(isParser!(Parser, S)) {
    alias PT = ParserType!(Parser, S);
    static if(isSomeChar!PT){
      alias RT = immutable(PT)[];
    } else {
      alias RT = PT[];
    }

    auto arr = appender!(RT);

    size_t matchedLength = 0;
    while(true) {
      auto result = parser(parseInput(input.source, input.begin + matchedLength));
      if(!result.success) {
        if(arr.data.length >= this.atLeast) {
          return parseSuccess!RT(arr.data, matchedLength);
        } else {
          return parseFailure!RT(input, "expect at least " ~ this.atLeast.to!string ~ " matches, but got " ~ arr.data.length.to!string ~ " matches");
        }
      }

      arr ~= result.result;
      matchedLength += result.matchedLength;
    }
  }
}


@safe pure unittest {
  import parsed.combinators.chr : chr;
  import parsed.combinators.literal : literal;
  
  assert(parse!(chr('a').many)("aaabbb") == "aaa");
  assert(parse!(chr('a').many)("aaabbb").matchedLength == 3);
  assert(parse!(chr('a').many(10))("aaabbb").error.msg == "expect at least 10 matches, but got 3 matches");
  assert(parse!(literal("hoge").many)("hogehogehoge") == ["hoge", "hoge", "hoge"]);
}