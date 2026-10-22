//
// Created by davesaah on 22/10/2026.
//
module;
#include <string>
#include <variant>
export module token;

namespace token
{
    export enum class Keyword {
        EXIT,
        EXPORT,
        HISTORY,
    };

    export constexpr std::string_view to_string(const Keyword k)
    {
        switch (k) {
        case Keyword::EXIT:
            return "Keyword::EXIT";
        case Keyword::EXPORT:
            return "Keyword::EXPORT";
        case Keyword::HISTORY:
            return "Keyword::HISTORY";
        default:
            return "Keyword::<unknown>";
        }
    }

    export enum class Symbol {
        PIPE,
        EQUALS,
        END,
    };

    export constexpr std::string_view to_string(const Symbol s)
    {
        switch (s) {
        case Symbol::PIPE:
            return "Symbol::PIPE";
        case Symbol::EQUALS:
            return "Symbol::EQUALS";
        case Symbol::END:
            return "Symbol::END";
        default:
            return "Symbol::<unknown>";
        }
    }

    export enum class Shell {
        COMMAND,
        ARGUMENT,
    };

    export constexpr std::string_view to_string(const Shell sh)
    {
        switch (sh) {
        case Shell::COMMAND:
            return "Shell::COMMAND";
        case Shell::ARGUMENT:
            return "Shell::ARGUMENT";
        default:
            return "Shell::<unknown>";
        }
    }

    // this concept ensures that only enums with string views are valid
    template <typename E>
    concept NamedEnum = std::is_enum_v<E> && requires(E e) {
        { to_string(e) } -> std::convertible_to<std::string_view>;
    };

    export template <NamedEnum E> std::ostream& operator<<(std::ostream& os, E e)
    {
        return os << to_string(e);
    }

    export using TokenType = std::variant<Keyword, Symbol, Shell>;

    export struct Token {
        TokenType type;
        std::string literal;
    };

    export TokenType lookup(const std::string& value, const size_t& position)
    {
        if (value == "exit") {
            return Keyword::EXIT;
        }
        if (value == "history") {
            return Keyword::HISTORY;
        }
        if (value == "export") {
            return Keyword::EXPORT;
        }
        if (position == 0) {
            return Shell::COMMAND;
        }

        return Shell::ARGUMENT;
    }
} // namespace token