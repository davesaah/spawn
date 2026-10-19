//
// Created by davesaah on 02/10/2026.
//
module;
#include <optional>
#include <string>
export module environment;

namespace environment
{
    export std::optional<std::string> fetch(const std::string& var)
    {
        if (auto const env_val = getenv(var.c_str()); env_val != nullptr) {
            return env_val;
        }
        return {};
    }

    export void set(const std::string& name, const std::string& value)
    {
        setenv(name.c_str(), value.c_str(), 0);
    }

    export void set_default_environment()
    {
        // show colors in ls output
    }
} // namespace environment