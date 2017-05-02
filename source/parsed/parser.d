module parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeString;

public {
  import parsed.parse_input;
  import parsed.parse_result;
}


/// Concept of parser
template isParser(alias parser, S = string) if(isSomeString!S) {
  enum isParser = is(typeof({
    alias RT = typeof({
      ParseInput!S source = void;
      return parser(source);
    }());

    static assert(is(RT == ParseResult!T, T));
  }));
}

template isParser(Parser, S) if(isSomeString!S) {
  private Parser parser = void;
  enum isParser = isParser!(parser, S);
}

enum isSomeParser(alias parser) = isParser!(parser, string) || isParser!(parser, wstring) || isParser!(parser, dstring);

template isSomeParser(Parser) {
  private Parser parser = void;
  enum isSomeParser = isSomeParser!parser;
}

template ParserType(alias parser, S = string) if(isSomeString!S) {
  static if(isParser!(parser, S)) {
    alias RT = typeof({
      ParseInput!S source = void;
      return parser(source);
    }());

    static if(is(RT == ParseResult!T, T)) {
      alias ParserType = T;
    } else {
      static assert(0);
    }
  } else {
    alias ParserType = void;
  }
}

template ParserType(Parser, S) if(isSomeString!S) {
  private Parser parser = void;
  alias ParserType = ParserType!(parser, S);
}

template parse(alias parser) {
  ParseResult!(ParserType!(parser, S)) parse(S)(S source) if(isParser!(parser, S)) {
    auto input = parseInput(source);
    return parser(input);
  }
}


bool test(alias parser, S)(S source) if(isParser!(parser, S)) {
  const result = parse!(parser, S)(source);
  return result.success;
}