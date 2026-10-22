#include <iostream>
import parser;
import init;
// import executor;
import history;
import token;
import lexer;
using namespace std;

int main()
{
    ios_base::sync_with_stdio(false);

    auto history = history::HistoryState();
    history.ensure_state();

    // shell loop
    for (string _input;;) {
        cout << init::get_ps1();
        getline(cin, _input);

        // if nothing, skip
        if (_input.empty()) {
            continue;
        }

        // update history
        // history.append(_input);
        //
        // // Built-in commands
        // if (_input == "exit") {
        //     break;
        // }
        // if (_input == "history") {
        //     history.display();
        //     continue;
        // }
        //
        // // external command
        // auto const cmd_tokens = parser::parse_input(_input);

        auto const l = lexer::lexer(_input);
        auto const input_tokens = l.get_tokens();

        cout << "\ninput tokens:\n";
        for (auto const& input_token : input_tokens) {
            cout << input_token << "\n";
        }

        cout << "\ncmd tokens:\n";
        auto const cmd_tokens = parser::parse_input(input_tokens);
        for (auto const& cmd_token : cmd_tokens) {
            cout << cmd_token << "\n";
        }
        // executor::execute(cmd_tokens);
    }
}
