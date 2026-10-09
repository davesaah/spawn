//
// Created by davesaah on 02/10/2026.
//
module;
#include <optional>
#include <string>
export module environment;

namespace environment
{
    export std::optional<std::string> fetch_env(const std::string& var)
    {
        if (auto const env_val = getenv(var.c_str()); env_val != nullptr) {
            return env_val;
        }
        return {};
    }

    export class EnvData
    {
      private:
        const std::string _name;
        const std::string _value;

      public:
        explicit EnvData(std::string name, std::string value);
        [[nodiscard]] auto save_state() const;
    };

    EnvData::EnvData(std::string name, std::string value) : _name(std::move(name)), _value(std::move(value)) {}

    auto EnvData::save_state() const
    {
        setenv(_name.c_str(), _value.c_str(), 0);
        return fetch_env(_name);
    }

    export void set_default_environment()
    {
        // show colors in ls output
    }
} // namespace environment