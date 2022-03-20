/**
* Console colors library. Define the main symbols cwrite[f][ln], and color functions.
*
* Copyright: Guillaume Piolat 2014-2022.
* Copyright: Adam D. Ruppe 2013-2022.
* Copyright: Robert Pasiński 2012-2013.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module consolecolors;

import core.stdc.stdio: printf, FILE, fwrite, fflush, fputc;
import std.stdio : File, stdout;
import std.string: format, replace;
version(Windows) import core.sys.windows.windows;
version(Posix) import core.sys.posix.unistd;


// MAYDO Explain CCL here (Console Colors Language)

public:

/// In input language, cannot more than `CCL_MAX_NESTED_TAGS` levels of nested tags.
enum int CCL_MAX_NESTED_TAGS = 32;

/// An exception whose text is coloured, it follows the CCL language.
/// You can convert it back to a regular exception with `unescapeCCL(e.msg)`.
class CCLException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) @nogc @safe pure nothrow
         {
            super(msg, file, line, next);
         }

    this(string msg, Throwable next, string file = __FILE__,
         size_t line = __LINE__) @nogc @safe pure nothrow
         {
            super(msg, file, line, next);
         }
}

/// Return all available console string colors for this library.
string[] availableConsoleColors() pure nothrow @safe
{
    return [
        "black",  "red",  "green",  "orange",  "blue",  "magenta", "cyan", "lgrey", 
        "grey", "lred", "lgreen", "yellow", "lblue", "lmagenta", "lcyan", "white"
    ];
}

/// Return: true if `text` is valid, and thus suitable for `cwrite`.
bool isValidCCL(const(char)[] text) nothrow @trusted
{
    try
    {
        TermInterpreter term;
        term.initializeJustForParsing();
        term.interpret(text);
        return true;
    }
    catch(CCLException e)
    {
        return false;
    }
    catch(Exception e)
    {
        assert(false); // should only catch CCLException in this library.
    }
}

/// Escape arbitrary text to go into `cwrite` without changing colors.
/// '<', '>' and '&' are rewritten as entities.
/// Note: exception can have CCL text or non-CCL text.
///       CCL text must be written with `cwrite`.
const(char)[] escapeCCL(scope const(char)[] text) nothrow @trusted
{
    // PERF: this is bad.
    return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
}

pure nothrow @safe
{
    /// Terminal colors functions. Change foreground color of the text.
    /// This wraps the text around, for consumption into `cwrite` or equivalent.
    string black(const(char)[] text)        { return "<black>" ~ text ~ "</black>";            }
    ///ditto
    string red(const(char)[] text)          { return "<red>" ~ text ~ "</red>";                }
    ///ditto
    string green(const(char)[] text)        { return "<green>" ~ text ~ "</green>";            }
    ///ditto
    string orange(const(char)[] text)       { return "<orange>" ~ text ~ "</orange>";          }
    ///ditto
    string blue(const(char)[] text)         { return "<blue>" ~ text ~ "</blue>";              }
    ///ditto
    string magenta(const(char)[] text)      { return "<magenta>" ~ text ~ "</magenta>";        }
    ///ditto
    string cyan(const(char)[] text)         { return "<cyan>" ~ text ~ "</cyan>";              }
    ///ditto
    string lgrey(const(char)[] text)        { return "<lgrey>" ~ text ~ "</lgrey>";            }
    ///ditto
    string grey(const(char)[] text)         { return "<grey>" ~ text ~ "</grey>";              }
    ///ditto
    string lred(const(char)[] text)         { return "<lred>" ~ text ~ "</lred>";              }
    ///ditto
    string lgreen(const(char)[] text)       { return "<lgreen>" ~ text ~ "</lgreen>";          }
    ///ditto
    string yellow(const(char)[] text)       { return "<yellow>" ~ text ~ "</yellow>";          }
    ///ditto
    string lblue(const(char)[] text)        { return "<lblue>" ~ text ~ "</lblue>";            }
    ///ditto
    string lmagenta(const(char)[] text)     { return "<lmagenta>" ~ text ~ "</lmagenta>";      }
    ///ditto
    string lcyan(const(char)[] text)        { return "<lcyan>" ~ text ~ "</lcyan>";            }
    ///ditto
    string white(const(char)[] text)        { return "<white>" ~ text ~ "</white>";            }

    /// Change background color of the text.
    /// This wraps the text around, for consumption into `cwrite` or equivalent.
    string on_black(const(char)[] text)    { return "<on_black>" ~ text ~ "</on_black>";       }
    ///ditto
    string on_red(const(char)[] text)      { return "<on_red>" ~ text ~ "</on_red>";           }
    ///ditto
    string on_green(const(char)[] text)    { return "<on_green>" ~ text ~ "</on_green>";       }
    ///ditto
    string on_orange(const(char)[] text)   { return "<on_orange>" ~ text ~ "</on_orange>";     }
    ///ditto
    string on_blue(const(char)[] text)     { return "<on_blue>" ~ text ~ "</on_blue>";         }
    ///ditto
    string on_magenta(const(char)[] text)  { return "<on_magenta>" ~ text ~ "</on_magenta>";   }
    ///ditto
    string on_cyan(const(char)[] text)     { return "<on_cyan>" ~ text ~ "</on_cyan>";         }
    ///ditto
    string on_lgrey(const(char)[] text)    { return "<on_lgrey>" ~ text ~ "</on_lgrey>";       }
    ///ditto
    string on_grey(const(char)[] text)     { return "<on_grey>" ~ text ~ "</on_grey>";         }
    ///ditto
    string on_lred(const(char)[] text)     { return "<on_lred>" ~ text ~ "</on_lred>";         }
    ///ditto
    string on_lgreen(const(char)[] text)   { return "<on_lgreen>" ~ text ~ "</on_lgreen>";     }
    ///ditto
    string on_yellow(const(char)[] text)   { return "<on_yellow>" ~ text ~ "</on_yellow>";     }
    ///ditto
    string on_lblue(const(char)[] text)    { return "<on_lblue>" ~ text ~ "</on_lblue>";       }
    ///ditto
    string on_lmagenta(const(char)[] text) { return "<on_lmagenta>" ~ text ~ "</on_lmagenta>"; }
    ///ditto
    string on_lcyan(const(char)[] text)    { return "<on_lcyan>" ~ text ~ "</on_lcyan>";       }
    ///ditto
    string on_white(const(char)[] text)    { return "<on_white>" ~ text ~ "</on_white>";       }
}

/// Wraps text into a particular foreground color.
/// Wrong colourname gets ignored.
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
///    <black>, <red>, <green>, <orange>, <blue>, <magenta>, <cyan>, <lgrey>, 
///    <grey>, <lred>, <lgreen>, <yellow>, <lblue>, <lmagenta>, <lcyan>, <white>
/// 
/// Escaping:
/// - To pass '<' as text and not a tag, use &lt;
/// - To pass '>' as text and not a tag, use &gt;
/// - To pass '&' as text not an entity, use &amp;
void cwrite(T...)(T args)
{
    import std.conv : to;

    // PERF: meh
    string s = "";
    foreach(arg; args)
        s ~= to!string(arg);
    emitToTerminal(s);
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

/// Disable output console colors.
void disableConsoleColors()
{
    g_termInterpreter.disableColors();
}

    
// PRIVATE PARTS API START HERE
private:


// Implementation of `emitToTerminal`. This is a combined lexer/parser/emitter.
// It can throw Exception in case of misformat of the input text.
void emitToTerminal(scope const(char)[] s) @trusted
{
    TermInterpreter* term = &g_termInterpreter;
    try
    {        
        term.interpret(s);  
    }
    catch (CCLParseException e)
    {
        throw new CCLException(e.nicerMessage(s));
    }
    catch(CCLException e)
    {
        throw e;
    }
    catch (Exception e)
    {
        assert(false); // console-colors shoudln't throw colorless error messages itself
    }
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
    destroy(g_termInterpreter);
}

struct TermInterpreter
{
    void initialize()
    {
        if (stdoutIsTerminal)
        {
            if (_terminal.initialize())
            {
                _enableTerm = true;
                cstdout = stdout.getFP();
            }
        }
    }

    void initializeJustForParsing()
    {
        _enableTerm = false;
    }

    ~this() pure
    {
    }

    void disableColors()
    {
        _enableTerm = false;
    }

    /// Moves the interpreter forward, eventually do actions.
    void interpret(const(char)[] s)
    {
        // Init tag stack.
        // State is reset between all calls to interpret, so that errors can be eaten out.

        input = s;
        inputPos = 0;

        stack(0) = Tag(TermColor.unknown, TermColor.unknown, "html");
        _tagStackIndex = 0;

        setForeground(TermColor.initial);
        setBackground(TermColor.initial);

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
                        case TokenType.tagOpen:
                        {
                            enterTag(token.text, token.inputPos);
                            break;
                        }

                        case TokenType.tagClose:
                        {
                            exitTag(token.text, token.inputPos);
                            break;
                        }

                        case TokenType.tagOpenClose:
                        {
                            enterTag(token.text, token.inputPos);
                            exitTag(token.text, token.inputPos);
                            break;
                        }

                        case TokenType.text:
                        {
                            if (_enableTerm)
                                printf("%.*s", cast(int)token.text.length, token.text.ptr);
                            break;
                        }

                        case TokenType.endOfInput:
                            finished = true;
                            break;

                    }
                break;
            }
        }

        // Is there any unclosed tags?
        if (_tagStackIndex != 0)
        {
            throw new CCLParseException(stack(_tagStackIndex).inputPos,
                                        format("<lcyan>&lt;%s&gt;</lcyan> tag is open but never closed.", stack(_tagStackIndex).name));
        }
    }

private:
    bool _enableTerm = false;
    Terminal _terminal;

    FILE* cstdout;

    // Style/Tag stack
    static struct Tag
    {
        TermColor fg = TermColor.unknown;  // last applied foreground color
        TermColor bg = TermColor.unknown;  // last applied background color
        const(char)[] name; // last applied tag
        int inputPos; // position of the opening tag in input chars.
    }
    
    Tag[CCL_MAX_NESTED_TAGS+1] _stack;
    int _tagStackIndex;

    ref Tag stack(int index) nothrow @nogc return
    {
        return _stack[index];
    }

    ref Tag stackTop() nothrow @nogc return
    {
        return _stack[_tagStackIndex];
    }

    void enterTag(const(char)[] tagName, int inputPos)
    {
        if (_tagStackIndex >= CCL_MAX_NESTED_TAGS)
            throw new CCLException("Tag stack is full. Try using less color tags.");

        // dup top of stack, set foreground color
        _stack[_tagStackIndex + 1] = _stack[_tagStackIndex]; 
        _stack[_tagStackIndex + 1].name = tagName; // Note: this name doesn't outlive the line of text we write
        _stack[_tagStackIndex + 1].inputPos = inputPos;

        _tagStackIndex += 1;

        bool bg = false;
        if ((tagName.length >= 3) && (tagName[0..3] == "on_"))
        {
            tagName = tagName[3..$];
            bg = true;
        }       
    
        switch(tagName)
        {
            case "black":    setColor(TermColor.black,    bg); break;
            case "red":      setColor(TermColor.red,      bg); break;
            case "green":    setColor(TermColor.green,    bg); break;
            case "orange":   setColor(TermColor.orange,   bg); break;
            case "blue":     setColor(TermColor.blue,     bg); break;
            case "magenta":  setColor(TermColor.magenta,  bg); break;
            case "cyan":     setColor(TermColor.cyan,     bg); break;
            case "lgrey":    setColor(TermColor.lgrey,    bg); break;
            case "grey":     setColor(TermColor.grey,     bg); break;
            case "lred":     setColor(TermColor.lred,     bg); break;
            case "lgreen":   setColor(TermColor.lgreen,   bg); break;
            case "yellow":   setColor(TermColor.yellow,   bg); break;
            case "lblue":    setColor(TermColor.lblue,    bg); break;
            case "lmagenta": setColor(TermColor.lmagenta, bg); break;
            case "lcyan":    setColor(TermColor.lcyan,    bg); break;
            case "white":    setColor(TermColor.white,    bg); break;
            default:
                break; // unknown tag
        }
    }

    void setColor(TermColor c, bool bg) nothrow @nogc
    {
        if (bg) setBackground(c);
        else setForeground(c);
    }

    void setForeground(TermColor fg) nothrow @nogc
    {
        stackTop().fg = fg;
        if (_enableTerm)
            _terminal.setForegroundColor(stackTop().fg, &flushStdoutIfWindows);
    }

    void setBackground(TermColor bg) nothrow @nogc
    {
        stackTop().bg = bg;
        if (_enableTerm)
            _terminal.setBackgroundColor(stackTop().bg, &flushStdoutIfWindows);
    }

    void applyStyleOnTop()
    {
        if (_enableTerm)
        {
            // PERF: do this at once.
            _terminal.setForegroundColor(stackTop().fg, &flushStdoutIfWindows);
            _terminal.setBackgroundColor(stackTop().bg, &flushStdoutIfWindows);
        }
    }
    
    void exitTag(const(char)[] tagName, int inputPos)
    {
        if (_tagStackIndex <= 0)
            throw new CCLParseException(inputPos, format("unexpected <lcyan>&lt;/%s&gt;</lcyan> closing tag.", tagName));
        
        if (stackTop().name != tagName)
        {
            throw new CCLParseException(inputPos, 
                format("<lcyan>&lt;%s&gt;</lcyan> doesn't match closing tag <lcyan>&lt;/%s&gt;</lcyan>",
                stackTop().name, tagName));
        }

        // drop one state of stack, apply old style
        _tagStackIndex -= 1;        
        applyStyleOnTop();
    }

    // <parser>

    ParserState _parserState = ParserState.initial;
    enum ParserState
    {
        initial
    }

    // </parser>

    // <lexer>

    const(char)[] input;
    int inputPos;

    LexerState _lexerState = LexerState.initial;
    enum LexerState
    {
        initial,
        insideEntity,
        insideTag,
    }

    enum TokenType
    {
        tagOpen,      // <red>
        tagClose,     // </red>
        tagOpenClose, // <red/> 
        text,
        endOfInput
    }

    static struct Token
    {
        TokenType type;

        // name of tag, or text
        const(char)[] text = null; 

        // position in input text
        int inputPos = 0;
    }

    bool hasNextChar()
    {
        return inputPos < input.length;
    }

    char peek()
    {
        return input[inputPos];
    }

    const(char)[] lastNChars(int n)
    {
        return input[inputPos - n .. inputPos];
    }

    const(char)[] charsSincePos(int pos)
    {
        return input[pos .. inputPos];
    }

    void next()
    {
        inputPos += 1;
        assert(inputPos <= input.length);
    }

    void flushStdoutIfWindows() nothrow @nogc
    {
        version(Windows)
        {
            //  On windows, because the C stdlib is buffered, we need to flush()
            //  before changing color else text is going to be the next color.
            if (cstdout != null)
                fflush(cstdout);
        }
    }

    Token getNextToken()
    {
        Token r;
        r.inputPos = inputPos;

        if (!hasNextChar())
        {
            r.type = TokenType.endOfInput;
            return r;
        }
        else if (peek() == '<')
        {
            int posOfLt = inputPos;

            // it is a tag
            bool closeTag = false;
            next;
            if (!hasNextChar())
                throw new CCLParseException(inputPos - 1, "expected tag name after <lcyan>&lt;</lcyan>, perhaps you meant <lcyan>&amp;lt;</lcyan>?");

            char ch2 = peek();
            if (peek() == '/')
            {
                closeTag = true;
                next;
                if (!hasNextChar())
                    throw new CCLParseException(inputPos - 1, "expected tag name after <lcyan>&lt;/</lcyan>");
            }

            const(char)[] tagName;
            int startOfTagName = inputPos;
            
            while(hasNextChar())
            {
                char ch = peek();
                if (ch == '/')
                {
                    tagName = charsSincePos(startOfTagName);
                    if (closeTag)
                        throw new CCLParseException(startOfTagName - 2, format("invalid tag syntax <lcyan>&lt;/%s/&gt;</lcyan>", tagName));

                    next;
                    if (!hasNextChar())
                        throw new CCLParseException(inputPos, "expected <lcyan>&gt;</lcyan> after tag.");

                    if (peek() == '>')
                    {
                        next;

                        r.type = TokenType.tagOpenClose;
                        r.text = tagName;
                        return r;
                    }
                    else
                        throw new CCLException("Expected '&gt;' after '/'");
                }
                else if (ch == '>')
                {
                    tagName = charsSincePos(startOfTagName);
                    next;
                    r.type = closeTag ? TokenType.tagClose : TokenType.tagOpen;
                    r.text = tagName;
                    return r;
                }
                else
                {   
                    next;
                }
                // TODO: check chars are valid in HTML tags
            }
            if (closeTag)
                throw new CCLParseException(inputPos, format("unterminated tag <lcyan>&lt;/%s&gt;</lcyan>", charsSincePos(startOfTagName)));
            else
                throw new CCLParseException(posOfLt, "unterminated tag starting here, do you mean <lcyan>&amp;lt;</lcyan>?");
        }
        else if (peek() == '&')
        {
            // it is an HTML entity
            next;
            if (!hasNextChar())
                throw new CCLParseException(inputPos, "expected entity name after &amp;");

            int startOfEntity = inputPos;
            while(hasNextChar())
            {
                char ch = peek();
                if (ch == ';')
                {
                    const(char)[] entityName = charsSincePos(startOfEntity);
                    switch (entityName)
                    {
                        case "lt": r.text = "<"; break;
                        case "gt": r.text = ">"; break;
                        case "amp": r.text = "&"; break;
                        default: 
                            throw new CCLParseException(startOfEntity, format("unknown entity <lcyan>%s</lcyan>, do you mean <lcyan>&amp;lt;</lcyan>, <lcyan>&amp;gt;</lcyan> or <lcyan>&amp;amp;</lcyan>?", entityName));
                    }
                    next;
                    r.type = TokenType.text;
                    return r;
                }
                else if ((ch >= 'a' && ch <= 'z') || (ch >= 'a' && ch <= 'z'))
                {
                    next;
                }
                else
                    throw new CCLParseException(inputPos, "illegal character in entity, do you mean <lcyan>&amp;lt;</lcyan>, <lcyan>&amp;gt;</lcyan> or <lcyan>&amp;amp;</lcyan>?");
            }
            throw new CCLParseException(inputPos, "unfinished entity name, <lcyan>;</lcyan> probably missing. Or you mean <lcyan>&amp;amp;</lcyan>?");
        }
        else 
        {
            int startOfText = inputPos;
            while(hasNextChar())
            {
                char ch = peek();
                if (ch == '>')
                    throw new CCLException("Illegal character &gt;, use &amp;&gt; instead if intended");
                if (ch == '<') 
                    break;
                if (ch == '&') 
                    break;
                next;
            }
            assert(inputPos != startOfText);
            r.type = TokenType.text;
            r.text = charsSincePos(startOfText);
            return r;
        }
    }
}

nothrow @safe:

/// Those are the colors supported by `Terminal` (not the colors of the outside API).
/// Their value when positive is the value of Windows foreground colors.
enum TermColor : int
{
    unknown = -2,  // unknown color, for example when detection failed
    initial = -1,  // the color detected at creation of Terminal
    black   = 0,
    red,
    green,
    orange,
    blue,
    magenta,
    cyan,
    lgrey,
    grey,
    lred,
    lgreen,
    yellow,
    lblue,
    lmagenta,
    lcyan,
    white,
}


// Term provide the following API:
// - initialize(): capture existing colors, restore them in destructor
// - setForegroundColor(TermColor color)
// - setBackgroundColor(TermColor color)
struct Terminal
{
nothrow @nogc @safe:

    // Initialize the terminal.
    // Return: success. If false, don't use this instance.
    bool initialize() @trusted
    {
        version(Posix) 
        {
            _initialForegroundColor = TermColor.initial;
            _initialBackgroundColor = TermColor.initial;
            _currentForegroundColor = _initialForegroundColor;
            _currentBackgroundColor = _initialBackgroundColor;
            return true;
        }
        else version(Windows)
        {
            // saves console attributes
            _console = GetStdHandle(STD_OUTPUT_HANDLE);
            if (_console == null)
                return false;
            CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
            if (_console && GetConsoleScreenBufferInfo(_console, &consoleInfo) != 0)
            {
                _currentAttr = consoleInfo.wAttributes;

                _initialForegroundColor = convertWinattrToTermColor(_currentAttr, false);
                _initialBackgroundColor = convertWinattrToTermColor(_currentAttr, true);

                _currentForegroundColor = _initialForegroundColor;
                _currentBackgroundColor = _initialBackgroundColor;
                return true;
            }
            else
                return false;
        }
        else
            static assert(false);
    }

    ~this() @trusted
    {
        // Note that this is also destructed if constructor failed (.init)
        // so have to handle it anyway like most D objects.
        if (!_initialized)
            return;

        version(Posix)
        {
            printf("\x1B[0m");
        }
        else version(Windows)
        {            
            setForegroundColor(_initialForegroundColor, null);
            setBackgroundColor(_initialBackgroundColor, null);
        }
        else
            static assert(false);
    }

    void setForegroundColor(TermColor color, 
                            scope void delegate() nothrow @nogc callThisBeforeChangingColor  ) @trusted
    {
        assert(color != TermColor.unknown);

        if (color == TermColor.initial)
            color = _initialForegroundColor;

        if (_currentForegroundColor == color)
            return;
        _currentForegroundColor = color;

        if (callThisBeforeChangingColor)
            callThisBeforeChangingColor();
        version(Posix)
        {
            int code = convertTermColorToVT100Attr(color, false);
            printf("\x1B[%dm", code);
        }
        else version(Windows)
        {
            WORD attr = cast(WORD)( (_currentAttr & ~FOREGROUND_MASK) | convertTermColorToWinAttr(color, false) );
            SetConsoleTextAttribute(_console, attr);
            _currentAttr = attr;
        }
        else
            static assert(false);
    }

    void setBackgroundColor(TermColor color, scope void delegate() nothrow @nogc callThisBeforeChangingColor) @trusted
    {
        assert(color != TermColor.unknown);

        if (color == TermColor.initial)
            color = _initialBackgroundColor;

        if (_currentBackgroundColor == color)
            return;
        _currentBackgroundColor = color;

        if (callThisBeforeChangingColor)
            callThisBeforeChangingColor();
        version(Posix)
        {
            int code = convertTermColorToVT100Attr(color, true);
            printf("\x1B[%dm", code);
        }
        else version(Windows)
        {
            WORD attr = cast(WORD)( (_currentAttr & ~BACKGROUND_MASK) | (convertTermColorToWinAttr(color, true)) );
            SetConsoleTextAttribute(_console, attr);
            _currentAttr = attr;
        }
        else
            static assert(false);
    }

private:

    // Successfully initialized.
    bool _initialized = false;

    // At initialization, find those.
    TermColor _initialForegroundColor = TermColor.unknown;
    TermColor _initialBackgroundColor = TermColor.unknown;

    // Act as cache to avoid useless syscalls.
    TermColor _currentForegroundColor = TermColor.unknown;
    TermColor _currentBackgroundColor = TermColor.unknown;

    version(Windows)
    {
        HANDLE _console;   // console handle.
        WORD _currentAttr; // Last known cached console attribute.
        CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
    }

    version(Windows)
    {
        enum int BACKGROUND_MASK = (BACKGROUND_BLUE | BACKGROUND_GREEN | BACKGROUND_RED | BACKGROUND_INTENSITY);
        enum int FOREGROUND_MASK = (FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);

        // Note: rotation, LUT works in both direction.
        static immutable ubyte[16] TRANSLATE_WINATTR = [ 0,  4,  2,  6, 1,  5,  3, 7, 8, 12, 10, 14, 9, 13, 11, 15 ];
    }

    TermColor convertWinattrToTermColor(int attrUnmasked, bool bg)
    {
        if (bg) attrUnmasked = attrUnmasked >>> 4;
        return cast(TermColor) TRANSLATE_WINATTR[attrUnmasked & 15];
    }

    /// Return a mask representing windows attribute for color c.
    int convertTermColorToWinAttr(TermColor c, bool bg)
    {
        assert (c != TermColor.unknown);
        if (c == TermColor.initial)
            return bg ? _initialBackgroundColor : _initialForegroundColor;
        else
        {
            int res = TRANSLATE_WINATTR[cast(ubyte)c];
            if (bg) res = res << 4;
            return res;
        }
    }

    int convertTermColorToVT100Attr(TermColor c, bool bg)
    {
        assert (c != TermColor.unknown);

        int res;

        if (c == TermColor.initial)
        {
            res = 39;
        }
        else
        {
            int lowbits = c & 7;
            bool intensity = (c & 8) != 0;
            res = 30 + lowbits;
            if (intensity) res += 60;
        }

        if (bg) res += 10;

        return res;
    }
}

// Terminal is only valid to use on an actual console device or terminal
// handle. You should not attempt to construct a Terminal instance if this
// returns false.
bool stdoutIsTerminal() @nogc @trusted
{
    version(Posix) 
    {
        return cast(bool) isatty(1);
    } 
    else version(Windows) 
    {
        HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
        if (hConsole == INVALID_HANDLE_VALUE)
            return false;

        return GetFileType(hConsole) == FILE_TYPE_CHAR;
    }
    else
        static assert(false);
}

// Here we describe the specifics of the Console Colors Language.
unittest
{
    // VALID: regular input.
    assert(isValidCCL( "<green>text</green>"));

    // VALID: unknown tag.
    assert(isValidCCL( "<unknown>text</unknown>"));

    // VALID: open-closed tag.
    assert(isValidCCL( "<autonomous/>"));

    // VALID: nested.
    assert(isValidCCL( "<green>text<red>lol</red></green>"));

    // VALID: UTF-8 multibyte characters.
    assert(isValidCCL( "<green>Hé ça va là?</green>"));

    // VALID: 32 levels of nesting.
    enum string x32OpeningTags = "<r><r><r><r><r><r><r><r><r><r><r><r><r><r><r><r>"
                               ~ "<r><r><r><r><r><r><r><r><r><r><r><r><r><r><r><r>";
    enum string x32ClosingTags = "</r></r></r></r></r></r></r></r></r></r></r></r></r></r></r></r>"
                               ~ "</r></r></r></r></r></r></r></r></r></r></r></r></r></r></r></r>";
    assert(isValidCCL(x32OpeningTags ~ "text" ~ x32ClosingTags));

    // INVALID: 33 levels of nesting.
    assert(!isValidCCL(x32OpeningTags ~ "<a>text</a>" ~ x32ClosingTags));

    // INVALID: unexpected closing tag
    assert(!isValidCCL("text</blue>"));

    // INVALID: unclosed opening tag
    assert(!isValidCCL("text<blue>"));

    // INVALID: tag mismatch
    assert(!isValidCCL("<a>text</b>"));

    // INVALID: input ending on <
    assert(!isValidCCL("my input <"));

    // INVALID: input ending on </
    assert(!isValidCCL("my input </"));

    // INVALID: tags like </this/>
    assert(!isValidCCL("</this/>"));

    // INVALID: unterminated open-close tag
    assert(!isValidCCL("<red/"));

    // INVALID: unterminated tag
    assert(!isValidCCL("<important"));
    assert(!isValidCCL("</important"));

    // INVALID: expected '>' after '/'
    assert(!isValidCCL("<important/"));

    // INVALID: unterminated &entity;
    assert(!isValidCCL("&gt"));

    // INVALID: invalid character in entity name
    assert(!isValidCCL("&@;"));

    // INVALID: unknown entity name
    assert(!isValidCCL("&unknown;"));
}

/// When input text doesn't parse, it throws.
/// This exception is used internally to forge super nice error messages.
class CCLParseException : CCLException // parse error have themselves colors.
{
    this(int inputCol, string msg, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) @nogc @safe pure nothrow
         {
            _col = inputCol;
            _line = -1;
            super(msg, file, line, next);
         }

    this(int inputCol, string msg, Throwable next, string file = __FILE__,
         size_t line = __LINE__) @nogc @safe pure nothrow
         {
            _col = inputCol;
            _line = -1;
            super(msg, file, line, next);
         }

    // Quote the relevant input line, and make a nice ----------^ message.
    string nicerMessage(scope const(char)[] wholeInput) @trusted
    {
        assert(wholeInput.length != 0); // "" would not trigger errors
        // Returns:
        // 
        // msg
        // line of text with error
        // -------------^
        //

        int where = _col;
        assert(where >= 0 && where <= wholeInput.length);

        // Backtrack to find start and stop of line in the input.
        int start = where;
        if (start >= wholeInput.length)
        {
            start = cast(int)(wholeInput.length) - 1;
        }

        while(start > 0)
        {
            char ch = wholeInput[start - 1];
            if (ch == '\n' || ch == '\r' || ch == '\0')
                break;
            start--;
        }

        int end = where;
        while(end < wholeInput.length)
        {
            char ch = wholeInput[end];
            if (ch == '\n' || ch == '\r' || ch == '\0')
                break;
            end++;
        }

        char[] message = msg ~ "\n\n  <lcyan>" 
                       ~ escapeCCL(wholeInput[start..end]) ~ "</lcyan>\n  <yellow>";
        int arrowDist = where - start; 
        assert(arrowDist >= 0);
        for (int dist = 0; dist < arrowDist; ++dist)
        {
            message ~= "-";
        }
        message ~= "^</yellow>";
        return message.idup;
    }

private:
    int _col; // column in text position that didn't parse
    int _line; // line in input text position that didn't parse
}