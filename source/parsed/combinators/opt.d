module parsed.combinators.opt;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeString;
import std.typecons : Nullable;


nothrow pure @safe @nogc OptionalParser!Parser opt(Parser)(Parser parser) if(isSomeParser!Parser) {
  return OptionalParser!Parser(parser);
}


private struct OptionalParser(Parser) if(isSomeParser!Parser) {
  private Parser parser;

  nothrow pure @safe @nogc this(Parser parser) {
    this.parser = parser;
  }

  ParseResult!(Nullable!(ParserType!(Parser, S))) opCall(S)(ParseInput!S input) if(isParser!(Parser, S)) {
    alias RT = ParserType!(Parser, S);
    auto result = parser(input);

    if(result.success) {
      return parseSuccess(Nullable!RT(result.result), result.matchedLength);
    } else {
      return parseSuccess(Nullable!RT.init, 0);
    }
  }
}

@safe pure unittest {
  import parsed.combinators.literal;
  assert(parse!(literal("hoge").opt)("hogepiyo") == "hoge");
  assert(parse!(literal("hoge").opt)("hogepiyo").isNull == false);
  assert(parse!(literal("hoge").opt)("hogepiyo").matchedLength == 4);
  
  assert(parse!(literal("hoge").opt)("foobar").isNull);    
  assert(parse!(literal("hoge").opt)("foobar").matchedLength == 0);  
}