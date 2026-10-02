#include <bits/local_lim.h>
#include <iostream>
#include <optional>
#include <unistd.h>
using namespace std;

namespace
{
    optional<string> get_username()
    {
        char username[LOGIN_NAME_MAX];

        // Retrieve logged-in user for the active terminal session
        if (getlogin_r(username, sizeof(username)) == 0)
        {
            return username;
        }

        // Fallback to environment variable
        // TODO: Revisit after environment variable subsystem implementation
        if (auto env_user = getenv("USER"); env_user != nullptr)
        {
            return env_user;
        }
        return {};
    }

    optional<string> get_hostname()
    {
        char hostname[HOST_NAME_MAX];

        if (gethostname(hostname, sizeof(hostname)) == 0)
        {
            return hostname;
        }

        // Fallback to environment variable
        // TODO: Revisit after environment variable subsystem implementation
        if (auto env_hostname = getenv("HOSTNAME"); env_hostname != nullptr)
        {
            return env_hostname;
        }
        return {};
    }

    // PS1 is the prompt string for the shell
    // by default, it will be username@hostname
    string get_ps1()
    {
        auto const username = get_username().value_or("user");
        auto const hostname = get_hostname().value_or("pc");
        return username + "@" + hostname + "$ ";
    }
} // namespace

int main()
{
    ios_base::sync_with_stdio(false);

    for (string _input; _input != "exit";)
    {
        cout << get_ps1();
        getline(cin, _input);
        cout << _input << "\n";
    }
}
