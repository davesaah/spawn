//
// Created by davesaah on 02/10/2026.
//
module;
#include <string>
#include <span>
#include <vector>
#include <sstream>
export module parser;

// contains everything needed for parsing user input
namespace parser
{
    export class CommandTable
    {
    public:
        explicit CommandTable(const std::string& input)
        {
            std::stringstream ss(input);
            std::getline(ss, program, ' ');

            std::string arg;
            while (std::getline(ss, arg, ' '))
            {
                args.push_back(arg);
            }
        };

        [[nodiscard]] std::string get_program() const
        {
            return program;
        }

        [[nodiscard]] std::span<const std::string> get_args() const
        {
            return args;
        }

    private:
        std::string program;
        std::vector<std::string> args;
    };
}
