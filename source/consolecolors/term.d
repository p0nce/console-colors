/**
* Portable terminal colors. This module is entirely private to console-colors.
*
* Copyright: Guillaume Piolat 2014-2022.
* Copyright: Adam D. Ruppe 2013-2022.
* Copyright: Robert Pasiński 2012-2013.
* License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module consolecolors.term;

version(Windows) import core.sys.windows.windows;
version(Posix) import core.sys.posix.unistd;

nothrow @nogc @safe:

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
            _initialForegroundColor = Color.initial;
            _initialBackgroundColor = Color.initial;
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

    ~this()
    {
        // Note that this is also destructed if constructor failed (.init)
        // so have to handle it anyway like most D objects.
        if (!_initialized)
            return;

        version(Windows)
        {            
            setForegroundColor(_initialForegroundColor, null);
            setBackgroundColor(_initialBackgroundColor, null);
        }
        else version(Posix)
        {
            printf("\x1B[0m", code);
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
        version(Windows)
        {
            WORD attr = cast(WORD)( (_currentAttr & ~FOREGROUND_MASK) | convertTermColorToWinAttr(color, false) );
            SetConsoleTextAttribute(_console, attr);
            _currentAttr = attr;
        }
        else version(Posix)
        {
            int code = convertTermColorToVT100Attr(color, false);
            printf("\x1B[%dm", code);
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
        version(Windows)
        {
            WORD attr = cast(WORD)( (_currentAttr & ~BACKGROUND_MASK) | (convertTermColorToWinAttr(color, true)) );
            SetConsoleTextAttribute(_console, attr);
            _currentAttr = attr;
        }
        else version(Posix)
        {
            int code = convertTermColorToVT100Attr(color, true);
            printf("\x1B[%dm", code);
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
    }

    TermColor convertWinattrToTermColor(int attrUnmasked, bool bg)
    {
        if (bg)
            attrUnmasked = attrUnmasked >>> 4;

        int col = attrUnmasked & 15; // take only 4 bit color
        static immutable ubyte[16] translate =
        [
            0,  4,  2,  6, 1,  5,  3, 7,
            8, 12, 10, 14, 9, 13, 11, 15
        ];

        return cast(TermColor) translate[col];
    }

    /// Return a mask representing windows attribute for color c.
    int convertTermColorToWinAttr(TermColor c, bool bg)
    {
        assert (c != TermColor.unknown);
        if (c == TermColor.initial)
            return bg ? _initialBackgroundColor : _initialForegroundColor;
        else
        {
            static immutable ubyte[16] translate =
            [
                0,  4,  2,  6, 1,  5,  3, 7,
                8, 12, 10, 14, 9, 13, 11, 15
            ];

            int res = translate[cast(ubyte)c];

            if (bg)
                res = res << 4;
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
bool stdoutIsTerminal() @trusted
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
