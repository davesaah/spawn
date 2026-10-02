//
// Created by davesaah on 02/10/2026.
//
module;
#include <string>
#include <vector>
#include <sstream>
export module parser;

// contains everything needed for parsing user input
namespace parser
{
    static void remove_quotes(std::string& str)
    {
        std::erase_if(str, [](const char c) { return c == '"' || c == '\''; });
    }

    static std::vector<std::string> tokenize(const std::string& input)
    {
        std::istringstream istream(input);
        std::vector<std::string> tokens;

        std::string token;
        while (istream >> token)
        {
            remove_quotes(token);
            tokens.push_back(token);
        }

        return tokens;
    }

    // converts input into an array of c_strings
    export std::vector<char*> parse_input(const std::string& input)
    {
        std::vector<char*> c_args;

        for (auto tokens = tokenize(input); auto& token : tokens)
        {
            c_args.push_back(token.data());
        }
        c_args.push_back(nullptr); // must be null terminated

        return c_args;
    }
}
