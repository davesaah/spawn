//
// Created by davesaah on 02/10/2026.
//
module;
#include <string>
#include <cstdlib>
#include <optional>
export module configuration;

namespace environment
{
    export std::optional<std::string> fetch_env(const std::string& var)
    {
        if (auto env_val = getenv(var.c_str()); env_val != nullptr)
        {
            return env_val;
        }
        return {};
    }
}
