/* A small program to replace xbacklight which does not
 * work on my system. Should run suid root if you want
 * to actually modify the brightness.
 * Compile with -std=c++11
 */

/* Usage :
 * 'brightness' will print the current and max brightness
 *  (does't require root privileges)
 * 'brightness 42' sets the brightness level to 42
 * 'brightness +12' increase the brightness level by 12
 * 'brightness -20' decrease the brightness level by 20
 *
 * Brightness will be capped between 0 and the max allowed value
 */

#include <cstdio>
#include <cstdlib>
#include <string>
#include <iostream>

// The /sys/ subfolder corresponding to the backlight control.
const char* g_folder = "/sys/class/backlight/intel_backlight";

// Command-line parsing structures
enum Status { PRINT, ABSOLUTE, PLUS, MINUS, ERROR };

struct Args
{
    Status mode; // Which action to perform
    int value;   // Value of the argument
};

// Parse the arguments
Args parse( int argc, char**argv )
{
    Args result;
    result.mode = ERROR;
    switch(argc)
    {
        case 1:
            result.mode = PRINT;
            break;
        case 2:
            std::string arg1(argv[1]);
            if(arg1[0] == '+'){
                result.mode = PLUS;
            } else if (arg1[0] == '-'){
                result.mode = MINUS;
            } else {
                result.mode = ABSOLUTE;
            }
            result.value = std::stoi(arg1);
            break;
    }
    return result;
}

// Read a value from a given file
int read_value( const char* endpath )
{
    std::string filename(g_folder);
    filename+="/";
    filename+=endpath;

    // Open the file
    FILE* file = fopen(filename.c_str(), "r");
    if (!file)
    {
        std::cerr<<"Error : cannot open "<<endpath<<std::endl;
        perror("read_value");
        exit(EXIT_FAILURE);
    }

    // Read value and close the file
    int result = -1;
    int ok = fscanf(file, "%d", &result);
    fclose(file);

    if (!ok)
    {
        std::cerr<<"Error : cannot read from "<<endpath<<std::endl;
        perror("read_value");
        exit(EXIT_FAILURE);
    }
    return result;
}

// Write value to a given file (will require root)
void write_value( const char* endpath, int value )
{
    std::string filename(g_folder);
    filename+="/";
    filename+=endpath;

    FILE* file = fopen(filename.c_str(), "w");
    if (!file)
    {
        std::cerr<<"Error : cannot open "<<endpath<<std::endl;
        perror("write_value");
        exit(EXIT_FAILURE);
    }

    int ok = fprintf( file, "%d", value);
    fclose(file);
    if (!ok){
        std::cerr<<"Error : cannot write to "<<endpath<<std::endl;
        exit(EXIT_FAILURE);
    }
}

void print_usage()
{
    printf(
            "Usage :\n"
            " 'brightness' will print the current and max brightness\n"
            " (does't require root privileges)\n"
            " 'brightness 42' sets the brightness level to 42\n"
            " 'brightness +12' increase the brightness level by 12\n"
            " 'brightness -20' decrease the brightness level by 20\n"
            "\n"
            " Brightness will be capped between 0 and the max allowed value\n");
}

// clamp a value between min and max
int clamp ( int value, int min, int max )
{
    return std::min(max, std::max(min, value));
}

int main( int argc, char** argv )
{
    // Parse args and read values
    const Args args = parse(argc,argv);
    const int current = read_value("actual_brightness");
    const int max = read_value("max_brightness");

    int newval = current;

    switch (args.mode)
    {
        case PRINT:
            std::cout<<current<<" / "<<max<<std::endl;
            break;

        case PLUS:
        case MINUS: // args.value is negtive in this case.
            newval = clamp(current + args.value, 0, max);
            write_value("brightness", newval);
            break;
        case ABSOLUTE:
            newval = clamp(args.value, 0, max);
            write_value("brightness", newval);
            break;

        case ERROR:
            print_usage();
            break;
    }

    // Return 0 if everything went fine, and 1 if not.
    return args.mode == ERROR;
}
