#include <iostream>
import parser;
import init;
import executor;
import environment;
import history;
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
        history.append(_input);

        // Built-in commands
        if (_input == "exit") {
            break;
        }
        if (_input == "history") {
            history.display();
            continue;
        }

        // external command
        auto const cmd_tokens = parser::parse_input(_input);
        executor::execute(cmd_tokens);
    }
}
