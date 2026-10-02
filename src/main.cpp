#include <iostream>
import parser;
import init;
using namespace std;

int main()
{
    ios_base::sync_with_stdio(false);

    // shell loop
    for (string _input; _input != "exit";)
    {
        cout << init::get_ps1();
        getline(cin, _input);
        auto const command_table = parser::CommandTable(_input);
        cout << "program: " << command_table.get_program() << "\n";

        cout << "args: ";
        for (const auto& arg : command_table.get_args())
        {
            cout << arg << " ";
        }
        cout << "\n";
    }
}
