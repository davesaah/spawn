//
// Created by davesaah on 22/10/2026.
//

module;
#include <string>
#include <utility>
#include <variant>
#include <vector>
export module lexer;
import token;

namespace lexer
{
    export class lexer
    {
      public:
        explicit lexer(std::string _input);
        [[nodiscard]] token::Token get_next_token() const;
        [[nodiscard]] std::vector<token::Token> get_tokens() const;

      private:
        std::string input;
        mutable char current_char{};
        mutable size_t current_position{};
        mutable size_t next_position{};
        mutable std::vector<token::Token> tokens{};

        friend void read_next_char(const lexer&);
        friend bool is_whitespace(const char&);
        friend std::string get_str_literal(const lexer&, size_t);
    };

    std::vector<token::Token> lexer::get_tokens() const
    {
        if (!tokens.empty()) {
            return tokens;
        }

        for (auto _token = get_next_token(); _token.type != token::TokenType{token::Symbol::END};
             _token = get_next_token()) {
            tokens.push_back(_token);
        }

        return tokens;
    }

    void read_next_char(const lexer& l)
    {
        if (l.next_position >= l.input.length()) {
            l.current_char = 0; // ASCII NULL
            l.current_position = l.input.length();
            return;
        }

        l.current_char = l.input[l.next_position];
        l.current_position = l.next_position;
        l.next_position++;
    }

    lexer::lexer(std::string _input) : input(std::move(_input))
    {
        read_next_char(*this);
    }

    bool is_whitespace(const char& c)
    {
        return c == ' ' || c == '\t';
    }

    std::string get_str_literal(const lexer& l, const size_t start)
    {
        while (l.current_char != 0 && !is_whitespace(l.current_char)) {
            read_next_char(l);
        }
        return l.input.substr(start, l.current_position);
    }

    token::Token lexer::get_next_token() const
    {
        while (is_whitespace(current_char)) {
            read_next_char(*this);
        }

        const auto start = current_position;
        auto tok = token::Token();

        switch (current_char) {
        case 0:
            tok.type = token::Symbol::END;
            return tok;
        case '|':
            tok.type = token::Symbol::PIPE;
            break;
        case '=':
            tok.type = token::Symbol::EQUALS;
            break;
        case '$':
            tok.type = token::Shell::ENVIRONMENT;
            break;
        default:
            tok.literal = get_str_literal(*this, start);
            tok.type = token::lookup(tok.literal, start);
            return tok;
        }

        // tok.literal = input.substr(start, current_position + 1);
        tok.literal = get_str_literal(*this, start);
        read_next_char(*this);
        return tok;
    }
} // namespace lexer