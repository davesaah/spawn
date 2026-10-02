#include <iostream>
import parser;
import init;
import executor;
import configuration;
using namespace std;

int main()
{
    ios_base::sync_with_stdio(false);

    // shell loop
    for (string _input;;)
    {
        cout << init::get_ps1();
        getline(cin, _input);

        // if nothing, skip
        if (_input.empty()) { continue; }

        // Built-in commands
        if (_input == "exit") { break; }

        // external command
        auto const cmd_tokens = parser::parse_input(_input);
        executor::execute(cmd_tokens);
    }
}
