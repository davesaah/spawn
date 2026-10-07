//
// Created by davesaah on 02/10/2026.
//
module;
#include <sstream>
#include <string>
#include <vector>
export module parser;
import configuration;

// contains everything needed for parsing user input
namespace parser
{
    namespace
    {
        void remove_quotes(std::string &str)
        {
            std::erase_if(str,
                          [](const char c) { return c == '"' || c == '\''; });
        }

        [[nodiscard]]
        std::string replace_env_val(const std::string &str)
        {
            // pattern for env variables must start with '$' and followed by
            // text
            if (!str.empty() && str.at(0) == '$' && str.size() >= 2 &&
                std::isalpha(str.at(1))) {
                const auto env_name = str.substr(1, str.size() - 1);
                return environment::fetch_env(env_name).value_or("");
            }

            return str;
        }
    } // namespace

    export std::vector<std::string> parse_input(const std::string &input)
    {
        std::istringstream istream(input);
        std::vector<std::string> tokens;

        std::string token;
        while (istream >> token) {
            remove_quotes(token);
            token = replace_env_val(token);
            tokens.push_back(token);
        }

        return tokens;
    }
} // namespace parser
