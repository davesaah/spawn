//
// Created by davesaah on 02/10/2026.
//
module;
#include <string>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <optional>
export module configuration;

namespace environment
{
    export std::optional<std::string> fetch_env(const std::string& var)
    {
        if (auto const env_val = getenv(var.c_str()); env_val != nullptr)
        {
            return env_val;
        }
        return {};
    }
}

namespace history
{
    namespace fs = std::filesystem;
    const auto home_path = environment::fetch_env("HOME").value();
    const fs::path xdg_state_home = environment::fetch_env("XDG_STATE_HOME")
        .value_or(home_path + "/.local/state");

    export class HistoryState
    {
    public:
        explicit HistoryState();
        void ensure_state();
        void display();
        void append(const std::string& input);

    private:
        fs::path history_file;
        std::fstream history_io;
    };

    HistoryState::HistoryState() :
        history_file(xdg_state_home / "spawn" / "history"),
        history_io(
            history_file,
            std::ios::in | std::ios::out | std::ios::app
        )
    {
        fs::create_directories(history_file.parent_path());
    }

    void HistoryState::ensure_state()
    {
        if (!history_io.is_open())
        {
            std::cerr << "unable to create history file" << "\n";
        }
    }

    void HistoryState::display()
    {
        history_io.clear();
        history_io.seekg(0, std::ios::beg);
        for (std::string line; getline(history_io, line);)
        {
            std::cout << line << "\n";
        }
    }

    void HistoryState::append(const std::string& input)
    {
        history_io.clear();
        history_io << input << "\n";
        history_io.flush();
    }
}
