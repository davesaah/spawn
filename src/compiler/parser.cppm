//
// Created by davesaah on 02/10/2026.
//
module;
#include <sstream>
#include <variant>
#include <vector>
export module parser;
import environment;
import token;

// contains everything needed for parsing user input
namespace parser
{
    namespace
    {
        void remove_quotes(std::string& str)
        {
            std::erase_if(str, [](const char c) { return c == '"' || c == '\''; });
        }

        [[nodiscard]]
        std::string _remove_quotes(std::string str)
        {
            std::erase_if(str, [](const char c) { return c == '"' || c == '\''; });
            return str;
        }

        [[nodiscard]]
        std::string replace_env_val(const std::string& str)
        {
            // pattern for env variables must start with '$' and followed by
            // text
            if (!str.empty() && str.at(0) == '$' && str.size() >= 2 && std::isalpha(str.at(1))) {
                const auto env_name = str.substr(1, str.size() - 1);
                return environment::fetch(env_name).value_or("");
            }

            return str;
        }
    } // namespace

    export std::vector<std::string> parse_input(const std::vector<token::Token>& input_tokens)
    {
        std::vector<std::string> cmd_tokens;
        cmd_tokens.reserve(input_tokens.size());

        for (const auto& token : input_tokens) {
            auto literal = _remove_quotes(token.literal);

            if (token.type == token::TokenType{token::Shell::ENVIRONMENT}) {
                literal = replace_env_val(literal);
            }

            cmd_tokens.push_back(std::move(literal));
        }

        return cmd_tokens;
    }

    export std::vector<std::string> parse_input(const std::string& input)
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
