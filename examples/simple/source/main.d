import consolecolors;
import std.format;


void main(string[] args)
{
    cwriteln( format("In this library, %s are nestable thanks to a state machine.".yellow, "text color".red));
    cwriteln("Here are all available colors:");
    cwriteln;
    cwriteln;
    cwriteln("FOREGROUND COLORS".white);
    cwriteln;
    foreach(c; availableConsoleColors)
    {
        cwritefln("<%s> - %8s </%s> <grey>(with &lt;%s&gt;)</grey>", c, c, c, c);
    }
    cwriteln;
    cwriteln;
    cwriteln("BACKGROUND COLORS".white);
    cwriteln;
    foreach(c; availableConsoleColors)
    {
        cwritefln("<on_%s> - %8s </on_%s> <grey>(&lt;on_%s&gt;)</grey>", c, c, c, c);
    }
}
