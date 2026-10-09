//
// Created by davesaah on 02/10/2026.
//
module;
#include <cstdlib>
#include <optional>
#include <string>
#include <unistd.h>
export module environment;

namespace environment
{
    export class EnvData
    {
      private:
        const char* _name;
        const char* _value;

      public:
        explicit EnvData(const std::string& name, const std::string& value)
            : _name(name.c_str()), _value(value.c_str())
        {
        }

        [[nodiscard]] const char* name() const { return _name; }
        [[nodiscard]] const char* value() const { return _value; }
    };

    export std::optional<std::string> fetch_env(const std::string& var)
    {
        if (auto const env_val = getenv(var.c_str()); env_val != nullptr) {
            return env_val;
        }
        return {};
    }

    // export std::optional<std::string> set_env(const EnvData& var)
    // {
    //     setenv(var.name(), var.value(), 0);
    // }
} // namespace environment
