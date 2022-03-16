/**
* Main API file. Define the main symbols cwrite[f][ln], and color functions.
*
* Copyright: Guillaume Piolat 2014-2022.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module consolecolors;

import arsd.terminal;

import core.stdc.stdio: FILE, fwrite, fflush, fputc;
import std.stdio : File, stdout;
import std.string: format;


public:

/// All available console colors for this library.
static immutable string[16] availableConsoleColors =
[
    "black",  "red",  "green",  "brown",  "blue",  "magenta", "cyan", "lgrey", 
    "grey", "lred", "lgreen", "yellow", "lblue", "lmagenta", "lcyan", "white"
];

pure nothrow @safe
{
    /// Terminal colors functions. Change foreground color of the text.
    /// This wraps the text around, for consumption into `cwrite` or equivalent.
    string black(const(char)[] text)
    {
        return "<black>" ~ text ~ "</black>";
    }
    ///ditto
    string red(const(char)[] text)
    {
        return "<red>" ~ text ~ "</red>";
    }
    ///ditto
    string green(const(char)[] text)
    {
        return "<green>" ~ text ~ "</green>";
    }
    ///ditto
    string brown(const(char)[] text)
    {
        return "<brown>" ~ text ~ "</brown>";
    }
    ///ditto
    string blue(const(char)[] text)
    {
        return "<blue>" ~ text ~ "</blue>";
    }
    ///ditto
    string magenta(const(char)[] text)
    {
        return "<magenta>" ~ text ~ "</magenta>";
    }
    ///ditto
    string cyan(const(char)[] text)
    {
        return "<cyan>" ~ text ~ "</cyan>";
    }
    ///ditto
    string lgrey(const(char)[] text)
    {
        return "<lgrey>" ~ text ~ "</lgrey>";
    }
    ///ditto
    string grey(const(char)[] text)
    {
        return "<grey>" ~ text ~ "</grey>";
    }
    ///ditto
    string lred(const(char)[] text)
    {
        return "<lred>" ~ text ~ "</lred>";
    }
    ///ditto
    string lgreen(const(char)[] text)
    {
        return "<lgreen>" ~ text ~ "</lgreen>";
    }
    ///ditto
    string yellow(const(char)[] text)
    {
        return "<yellow>" ~ text ~ "</yellow>";
    }
    ///ditto
    string lblue(const(char)[] text)
    {
        return "<lblue>" ~ text ~ "</lblue>";
    }
    ///ditto
    string lmagenta(const(char)[] text)
    {
        return "<lmagenta>" ~ text ~ "</lmagenta>";
    }
    ///ditto
    string lcyan(const(char)[] text)
    {
        return "<lcyan>" ~ text ~ "</lcyan>";
    }
    ///ditto
    string white(const(char)[] text)
    {
        return "<white>" ~ text ~ "</white>";
    }
}

/// Wraps text into a particular foreground color.
string color(const(char)[] text, const(char)[] color) pure @safe
{
    return format("<%s>%s</%s>", color, text, color);
}

/// Coloured `write`/`writef`/`writeln`/`writefln`.
///
/// The language that these function take as input can contain HTML tags.
/// Unknown tags have no effect and are removed.
/// Tags can't have attributes.
/// 
/// Accepted tags:
/// - <COLORNAME> such as:
///    <black>, <red>, <green>, <brown>, <blue>, <magenta>, <cyan>, <lgrey>, 
///    <grey>, <lred>, <lgreen>, <yellow>, <lblue>, <lmagenta>, <lcyan>, <white>
/// 
/// Escaping:
/// - To pass '<' as text and not a tag, use &lt; or &#60;
/// - To pass '>' as text and not a tag, use &gt; or &#62;
///
void cwrite(T...)(T args)
{
    import std.conv : to;

    // PERF: meh
    string s = "";
    foreach(arg; args)
        s ~= to!string(arg);

    int res = emitToTerminal(s);

    // Throw error if parsing error.
    switch(res)
    {
        case CC_ERR_OK: break;
        case CC_UNTERMINATED_TAG: throw new Exception("Unterminated <tag> in coloured text");
        case CC_UNKNOWN_TAG:      throw new Exception("Unknown <tag> in coloured text");
        case CC_MISMATCHED_TAG:   throw new Exception("Mismatched <tag> in coloured text");
        case CC_TERMINAL_ERROR:   throw new Exception("Unspecified terminal error");
        default:
            assert(false); // if you fail here, console-colors is buggy
    }
}

///ditto
void cwriteln(T...)(T args)
{
    // Most general instance
    cwrite(args, '\n');
}

///ditto
void cwritef(Char, T...)(in Char[] fmt, T args)
{
    import std.string : format;
    auto s = format(fmt, args);
    cwrite(s);
}

///ditto
void cwritefln(Char, T...)(in Char[] fmt, T args)
{
    cwritef(fmt ~ "\n", args);
}

    
// PRIVATE PARTS API START HERE
private:


enum int CC_ERR_OK = 0,           // "<blue>text</blue>"
         CC_UNTERMINATED_TAG = 1, // "<blue"
         CC_UNKNOWN_TAG = 2,      // "<pink>text</pink>"
         CC_MISMATCHED_TAG = 3,   // "<blue>text</red>"
         CC_TERMINAL_ERROR = 4;   // terminal.d error.

// Implementation of `emitToTerminal`. This is a combined lexer/parser/emitter.
// It can throw Exception in case of misformat of the input text.
int emitToTerminal( const(char)[] s) @trusted
{
    TermInterpreter* term = &g_termInterpreter;
    return term.interpret(s);
    /*

    version(Windows)
    {
        WinTermEmulation winterm;
        winterm.initialize();
        foreach(char ch ; s)
        {
            auto charAction = winterm.feed(ch);
            final switch(charAction) with (WinTermEmulation.CharAction)
            {
                case drop: break;
                case write: fputc(ch, cfile); break;
                case flush: fflush(cfile); break;
            }
        }
    }
    else
    {
        fwrite(cfile, s);
    }*/
//   return CC_ERR_OK;
}

private:

/// A global, shared state machine that does the terminal emulation and book-keeping.
TermInterpreter g_termInterpreter = TermInterpreter.init;

shared static this()
{
    g_termInterpreter.initialize();
}

shared static ~this()
{
}

struct TermInterpreter
{
    void initialize()
    {
        if (Terminal.stdoutIsTerminal)
        {
            _terminal = Terminal(ConsoleOutputType.linear);
            _enableTerm = true;
        }
    }

    void disableColors()
    {
        _enableTerm = false;
    }

    /// Moves the interpreter forward, eventually do actions.
    /// Return: error code.
    int interpret(const(char)[] s)
    {
        // Init tag stack.
        // State is reset between all calls to interpret, so that errors can be eaten out.

        bool finished = false;
        bool termTextWasOutput = false;
        while(!finished)
        {
            final switch (_parserState)
            {
                case ParserState.initial:

                    Token token = getNextToken();
                    final switch(token.type)
                    {
                        case TokenType.tag:

                        case TokenType.text:
                        {
                            if (_enableTerm)
                            {
                                try
                                {
                                    _terminal.write(token.text);
                                }
                                catch(Exception e)
                                {
                                    return CC_TERMINAL_ERROR;
                                }
                                termTextWasOutput = true;
                            }
                            else
                            {
                                stdout.write(token.text);
                            }
                            break;
                        }

                        case TokenType.endOfInput:
                            finished = true;
                            break;

                    }
                break;
            }
        }

        if (termTextWasOutput)
        {
            _terminal.flush();
        }

        return 0;
    }

private:
    bool _enableTerm = false;
    Terminal _terminal;

    ParserState _parserState = ParserState.initial;
    enum ParserState
    {
        initial
    }

    static struct Tag
    {
        int type; // 0 = open   1 = closed   2 = open and closed
        const(char)[] name; // tag name
    }

    enum TokenType
    {
        tag,
        text,
        endOfInput
    }

    static struct Token
    {
        TokenType type;

        // name of tag, or text
        const(char)[] text = null; 

        // position in input text
        int col = 0;
    }

    bool hasNextToken()
    {
        return false;
    }

    Token getNextToken()
    {
        Token tok;
        tok.type = TokenType.endOfInput;
        return tok;
    }
}