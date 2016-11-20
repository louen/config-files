#include <cstdio>
#include <cstdlib>

#include <string>
#include <iostream>

const char* g_folder = "/sys/class/backlight/intel_backlight";

enum Status { PRINT, ABSOLUTE, PLUS, MINUS, ERROR };

struct Args {
    Status mode;
    int value;
};

Args parse( int argc, char**argv)
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
        exit(EXIT_FAILURE);
    }
    return result;
}

void write_value( const char* endpath, int value)
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
}


int clamp ( int value, int min, int max)
{
    return std::min(max, std::max(min, value));
}

int main( int argc, char** argv)
{
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
            newval = clamp( current + args.value, 0, max);
            write_value("brightness", newval);
            break;
        case ABSOLUTE:
            newval = clamp( args.value, 0, max);
            write_value("brightness", newval);
            break;

        case ERROR:
            print_usage();
            break;
    }

    return args.mode == ERROR;
}


