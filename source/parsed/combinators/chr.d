module parsed.combinators.chr;
import parsed.parser;
import parsed.parse_input;
import parsed.parse_result;
import std.traits : isSomeString, isSomeChar, Unqual;
import std.range.primitives : ElementEncodingType;
import std.utf;
import std.array;
import std.conv : to;

nothrow pure @safe @nogc CharParser!C chr(C)(C c) if(isSomeChar!C) {
  return CharParser!C(c);
}

private struct CharParser(C) if(isSomeChar!C) {
  public nothrow @safe pure @nogc this(C c) {
    chara = c;
  }
  
  private C chara;
  public pure @safe ParseResult!(Unqual!(ElementEncodingType!S)) opCall(S)(ParseInput!S input) {
    alias SC = Unqual!(ElementEncodingType!S);
    
    if(input.empty) {
      return parseFailure!SC(input, "end of source");
    }
    auto c = chara.to!SC;
    if(input[0] == c) {
      return parseSuccess(c, 1);
    } else {
      return parseFailure!SC(input, "expect '" ~ chara.to!string ~ "', but got '" ~ input[0].to!string ~ "'");
    }
  }
}

///
@safe pure unittest {
  // char
  static assert(isParser!(chr('a'), string));
  static assert(isParser!(chr('a'), wstring));  
  static assert(isParser!(chr('a'), dstring));

  // wchar
  static assert(isParser!(chr('鮨'), wstring));
  static assert(isParser!(chr('鮨'), dstring));

  // dchar
  static assert(isParser!(chr('🍣'), dstring));

  assert(parse!(chr('a'))("").error.msg == "end of source");
  assert(parse!(chr('a'))("aa") == 'a');
  assert(parse!(chr('a'))("aa").matchedLength == 1);  
  assert(parse!(chr('a'))("bb").error.msg == "expect 'a', but got 'b'");
}