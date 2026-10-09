//
// Created by davesaah on 02/10/2026.
//
module;
#include <bits/local_lim.h>
#include <unistd.h>

#include <optional>
#include <string>
export module init;
import environment;

namespace init
{
    namespace
    {
        std::optional<std::string> get_username()
        {
            char username[LOGIN_NAME_MAX];

            // Retrieve logged-in user for the active terminal session
            if (getlogin_r(username, sizeof(username)) == 0) {
                return username;
            }

            // Fallback to environment variable
            return environment::fetch_env("USER");
        }

        std::optional<std::string> get_hostname()
        {
            char hostname[HOST_NAME_MAX];

            if (gethostname(hostname, sizeof(hostname)) == 0) {
                return hostname;
            }

            // Fallback to environment variable
            return environment::fetch_env("HOSTNAME");
        }
    } // namespace

    // PS1 is the prompt string for the shell
    // by default, it will be username@hostname
    export std::string get_ps1()
    {
        auto const username = get_username().value_or("user");
        auto const hostname = get_hostname().value_or("pc");
        return username + "@" + hostname + "$ ";
    }
} // namespace init
