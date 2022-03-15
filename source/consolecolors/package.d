/**
* Main API file. Define the main symbols cwrite[f][ln], and color functions.
*
* Copyright: Guillaume Piolat 2014-2022.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module consolecolors;

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
///
/// Accepted tags:
/// - <COLORNAME>
/// 
/// Escaping:
/// - To pass '<' as text and not a tag, use &lt; or &#60;
/// - To pass '>' as text and not a tag, use &gt; or &#62;
///
/// Available color names:
/// 
void cwrite(T...)(T args) if (!is(T[0] : File))
{
    stdout.cwrite(args);
}

/// Coloured `writef`.
void cwritef(Char, T...)(in Char[] fmt, T args) if (!is(T[0] : File))
{
    stdout.cwritef(fmt, args);
}

///ditto
void cwritefln(Char, T...)(in Char[] fmt, T args)
{
    stdout.cwritef(fmt ~ "\n", args);
}

///ditto
void cwriteln(T...)(T args)
{
    // Most general instance
    stdout.cwrite(args, '\n');
}

///ditto
void cwritef(Char, A...)(File f, in Char[] fmt, A args)
{
    import std.string : format;
    auto s = format(fmt, args);
    f.cwrite(s);
}

///ditto
void cwrite(S...)(File f, S args)
{
    import std.conv : to;

    // PERF: meh
    string s = "";
    foreach(arg; args)
        s ~= to!string(arg);

    FILE* file = f.getFP();


    // TEMP
    s = hack(s);

    int res = emitToTerminal(file, s);

    // Throw error if parsing error.
    switch(res)
    {
        case CC_ERR_OK: break;
        case CC_UNTERMINATED_TAG: throw new Exception("Unterminated <tag> in coloured text");
        case CC_UNKNOWN_TAG:      throw new Exception("Unknown <tag> in coloured text");
        case CC_MISMATCHED_TAG:   throw new Exception("Mismatched <tag> in coloured text");
        default:
            assert(false); // if you fail here, console-colors is buggy
    }
}

// TEMPORARY, very slow
string hack(string s)
{
    import std.string: replace;
    s = s.replace("<black>", "\033[30m");
    s = s.replace("</black>", "\033[0m");
    s = s.replace("<red>", "\033[31m");
    s = s.replace("</red>", "\033[0m");
    s = s.replace("<green>", "\033[32m");
    s = s.replace("</green>", "\033[0m");
    s = s.replace("<brown>", "\033[33m");
    s = s.replace("</brown>", "\033[0m");
    s = s.replace("<blue>", "\033[34m");
    s = s.replace("</blue>", "\033[0m");
    s = s.replace("<magenta>", "\033[35m");
    s = s.replace("</magenta>", "\033[0m");
    s = s.replace("<cyan>", "\033[36m");
    s = s.replace("</cyan>", "\033[0m");
    s = s.replace("<lgrey>", "\033[37m");
    s = s.replace("</lgrey>", "\033[0m");
    s = s.replace("<grey>", "\033[90m");
    s = s.replace("</grey>", "\033[0m");
    s = s.replace("<lred>", "\033[91m");
    s = s.replace("</lred>", "\033[0m");
    s = s.replace("<lgreen>", "\033[92m");
    s = s.replace("</lgreen>", "\033[0m");
    s = s.replace("<yellow>", "\033[93m");
    s = s.replace("</yellow>", "\033[0m");
    s = s.replace("<lblue>", "\033[94m");
    s = s.replace("</lblue>", "\033[0m");
    s = s.replace("<lmagenta>", "\033[95m");
    s = s.replace("</lmagenta>", "\033[0m");
    s = s.replace("<lcyan>", "\033[96m");
    s = s.replace("</lcyan>", "\033[0m");
    s = s.replace("<white>", "\033[97m");
    s = s.replace("</white>", "\033[0m");
    
/*
    "black",  "red",  "green",  "brown",  "blue",  "magenta", "cyan", "lgrey", 
        "grey", "lred", "lgreen", "yellow", "lblue", "lmagenta", "lcyan", "white"*/

    return s;
}

    
// PRIVATE PARTS API START HERE
private:


enum int CC_ERR_OK = 0,           // "<blue>text</blue>"
         CC_UNTERMINATED_TAG = 1, // "<blue"
         CC_UNKNOWN_TAG = 2,      // "<pink>text</pink>"
         CC_MISMATCHED_TAG = 3;   // "<blue>text</red>"

// Implementation of `emitToTerminal`. This is a combined lexer/parser/emitter.
// It can throw Exception in case of misformat of the input text.
int emitToTerminal(scope FILE* cfile, const(char)[] s) nothrow @nogc @safe
{
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
    }
    return CC_ERR_OK;
}


version(Windows)
{
    import core.sys.windows.windows;

    // This is a state machine to enable terminal colors on Windows.
    // Parses and interpret ANSI/VT100 Terminal Control Escape Sequences.
    // Only supports colour sequences, will output char incorrectly on invalid input.
    struct WinTermEmulation
    {
    public:
        @nogc void initialize() nothrow @trusted
        {
            // saves console attributes
            _console = GetStdHandle(STD_OUTPUT_HANDLE);
            _savedInitialColor = (0 != GetConsoleScreenBufferInfo(_console, &consoleInfo));
            _state = State.initial;
        }

        @nogc ~this() nothrow @trusted
        {
            // Restore initial text attributes on release
            if (_savedInitialColor)
            {
                SetConsoleTextAttribute(_console, consoleInfo.wAttributes);
                _savedInitialColor = false;
            }
        }

        enum CharAction
        {
            write,
            drop,
            flush
        }

        // Eat one character and update color state accordingly.
        // Returns what to do with the fed character.
        @nogc CharAction feed(dchar d) nothrow @trusted
        {
            final switch(_state) with (State)
            {
                case initial:
                    if (d == '\x1B')
                    {
                        _state = escaped;
                        return CharAction.flush;
                    }
                    break;

                case escaped:
                    if (d == '[')
                    {
                        _state = readingAttribute;
                        _parsedAttr = 0;
                        return CharAction.drop;
                    }
                    break;


                case readingAttribute:
                    if (d >= '0' && d <= '9')
                    {
                        _parsedAttr = _parsedAttr * 10 + (d - '0');
                        return CharAction.drop;
                    }
                    else if (d == ';')
                    {
                        executeAttribute(_parsedAttr);
                        _parsedAttr = 0;
                        return CharAction.drop;
                    }
                    else if (d == 'm')
                    {
                        executeAttribute(_parsedAttr);
                        _state = State.initial;
                        return CharAction.drop;
                    }
                    break;
            }
            return CharAction.write;
        }

    private:
        HANDLE _console;
        bool _savedInitialColor;
        CONSOLE_SCREEN_BUFFER_INFO consoleInfo;
        State _state;
        WORD _currentAttr;
        int _parsedAttr;

        enum State
        {
            initial,
            escaped,
            readingAttribute
        }

        @nogc void setForegroundColor(WORD fgFlags) nothrow @trusted
        {
            _currentAttr = _currentAttr & ~(FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
            _currentAttr = _currentAttr | fgFlags;
            SetConsoleTextAttribute(_console, _currentAttr);
        }

        @nogc void setBackgroundColor(WORD bgFlags) nothrow @trusted
        {
            _currentAttr = _currentAttr & ~(BACKGROUND_BLUE | BACKGROUND_GREEN | BACKGROUND_RED | BACKGROUND_INTENSITY);
            _currentAttr = _currentAttr | bgFlags;
            SetConsoleTextAttribute(_console, _currentAttr);
        }

        @nogc void executeAttribute(int attr) nothrow @trusted
        {
            switch (attr)
            {
                case 0:
                    // reset all attributes
                    SetConsoleTextAttribute(_console, consoleInfo.wAttributes);
                    break;

                default:
                    if ( (30 <= attr && attr <= 37) || (90 <= attr && attr <= 97) )
                    {
                        WORD color = 0;
                        if (90 <= attr && attr <= 97)
                        {
                            color = FOREGROUND_INTENSITY;
                            attr -= 60;
                        }
                        attr -= 30;
                        color |= (attr & 1 ? FOREGROUND_RED : 0) | (attr & 2 ? FOREGROUND_GREEN : 0) | (attr & 4 ? FOREGROUND_BLUE : 0);
                        setForegroundColor(color);
                    }

                    if ( (40 <= attr && attr <= 47) || (100 <= attr && attr <= 107) )
                    {
                        WORD color = 0;
                        if (100 <= attr && attr <= 107)
                        {
                            color = BACKGROUND_INTENSITY;
                            attr -= 60;
                        }
                        attr -= 40;
                        color |= (attr & 1 ? BACKGROUND_RED : 0) | (attr & 2 ? BACKGROUND_GREEN : 0) | (attr & 4 ? BACKGROUND_BLUE : 0);
                        setBackgroundColor(color);
                    }
            }
        }
    }
}
