#include <iostream>
import parser;
import init;
import executor;
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

        // Built-in command: exit
        if (_input == "exit") { break; }

        auto const cmd = parser::parse_input(_input);

        // external command
        executor::execute(cmd);
    }
}
