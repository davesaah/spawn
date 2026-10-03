//
// Created by davesaah on 02/10/2026.
//
module;
#include <iostream>
#include <unistd.h>
#include <vector>
#include <sys/wait.h>
export module executor;

namespace executor
{
    namespace
    {
        // converts input into an array of c_strings
        std::vector<char*> get_exec_array(const std::vector<std::string>& cmd_tokens)
        {
            std::vector<char*> c_args;

            for (const auto& token : cmd_tokens)
            {
                c_args.push_back(const_cast<char*>(token.data()));
            }
            c_args.push_back(nullptr); // must be null terminated

            return c_args;
        }
    }

    export void execute(const std::vector<std::string>& cmd_tokens)
    {
        const auto pid = fork();
        if (pid < 0)
        {
            std::cerr << "unable to start user process: " << cmd_tokens.at(0) << "\n";
            return;
        }

        // child process is available
        if (pid == 0)
        {
            const auto exec_arr = get_exec_array(cmd_tokens);
            execvp(exec_arr.at(0), exec_arr.data()); // if successful, it never returns

            // if it returns, then replacing with command contents failed
            std::cerr << "Command not found: " << cmd_tokens.at(0) << "\n";
            _exit(127); // terminate child process
        }

        // spawn should wait for child process to complete
        waitpid(pid, nullptr, 0);
    }
}
