//
// Created by davesaah on 02/10/2026.
//
module;
#include <iostream>
#include <unistd.h>
#include <vector>
#include <sys/wait.h>
export module executor;
import parser;

namespace executor
{
    export void execute(const std::vector<char*>& cmd)
    {
        const auto pid = fork();
        if (pid < 0)
        {
            std::cerr << "unable to start user process: " << cmd[0] << "\n";
            return;
        }

        if (pid == 0)
        {
            // child process is available
            execvp(cmd[0], cmd.data()); // if successful, it never returns

            // if it returns, then replacing with command contents failed
            std::cerr << "Command not found: " << cmd[0] << "\n";
            _exit(127); // terminate child process
        }

        // spawn should wait for child process to complete
        waitpid(pid, nullptr, 0);
    }
}
