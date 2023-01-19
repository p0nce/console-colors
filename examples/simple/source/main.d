import consolecolors;

void main(string[] args)
{
    try
    {
        cwriteln("Welcome to &gt;&gt;&gt; <yellow><on_blue> "
               ~ "console-colors </on_blue></yellow> &lt;&lt;&lt;");
        cwriteln;
        cwritefln("In this library, %s are nestable thanks to a state machine.\n".yellow, 
                  " text colors ".lmagenta.on_white);
        cwriteln;
        cwriteln("*** FOREGROUND COLORS".white);
        cwriteln;
        foreach(c; availableConsoleColors)
        {
            cwritefln("    <%s> - %8s </%s> <grey>with &lt;%s&gt; or .%s() </grey>", 
                      c, c, c, c, c);
        }
        cwriteln;
        cwriteln;
        cwriteln("*** BACKGROUND COLORS".white);
        cwriteln;
        foreach(c; availableConsoleColors)
        {
            cwritefln("    <on_%s> <white>- %8s</white> </on_%s> "
                    ~ "<grey>with &lt;on_%s&gt; or .on_%s()</grey>", c, c, c, c, c);
        }

        cwriteln;
        cwriteln("*** UNIVERSAL CLOSING TAG".white);
        cwriteln;
        cwriteln("    Closing <lgreen>nested <lcyan>tags <lmagenta>with just</><yellow> &lt;/&gt;</></></>");
    }
    catch(CCLException e) // An exception with a coloured message
    {
        cwritefln("\n<lred>Error:</lred> %s", e.msg);
    }
    catch(Exception e) // An uncoloured exception.
    {
        cwritefln("\n<lred>Error:</lred> %s", escapeCCL(e.msg));
    }
}
