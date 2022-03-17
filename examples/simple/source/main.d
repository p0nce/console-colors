import consolecolors;
import std.format;


void main(string[] args)
{
    cwriteln( format("In this library, %s are nestable thanks to a state machine.".yellow, "text color".red));
    cwriteln("Here are all available colors:");

    foreach(color; availableConsoleColors)
    {
        cwritefln("<%s> - %s </%s> <grey>(with &lt;%s&gt; and &lt;on_%s&gt;)</grey>", color, color, color, color, color);
    }
}
