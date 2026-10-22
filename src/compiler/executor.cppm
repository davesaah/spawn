//
// Created by davesaah on 02/10/2026.
//
module;
#include <sys/wait.h>
#include <iostream>
#include <vector>
export module executor;

namespace executor
{
    namespace
    {
        // converts input into an array of c_strings
        std::vector<char*> get_exec_array(const std::vector<std::string>& cmd_tokens)
        {
            std::vector<char*> c_args;

            for (const auto& token : cmd_tokens) {
                c_args.push_back(const_cast<char*>(token.data()));
            }
            c_args.push_back(nullptr); // must be null terminated

            return c_args;
        }
    } // namespace

    export void execute(const std::vector<std::string>& cmd_tokens, std::string* output = nullptr)
    {
        // Only standard output is captured. Standard error still goes to the terminal. To capture both, redirect
        // STDERR_FILENO to the pipe as well.

        // Pipe read errors: The example reports a read error but continues to wait for the child. A production
        // implementation should handle that case carefully, since a child can block if the parent stops reading while
        // the pipe is full.

        int pipe_fd[2] = {-1, -1}; // two-way pipe

        // create pipe if output is not null
        if (output != nullptr) {
            output->clear();

            if (pipe(pipe_fd) == -1) {
                std::cerr << "Failed to create internal pipe\n";
                return;
            }
        }

        const auto pid = fork();
        if (pid < 0) {
            std::cerr << "unable to start user process: " << cmd_tokens.at(0) << "\n";

            if (output != nullptr) {
                close(pipe_fd[0]);
                close(pipe_fd[1]);
            }
            return;
        }

        // child process is available
        if (pid == 0) {
            if (output != nullptr) {
                close(pipe_fd[0]);

                if (dup2(pipe_fd[1], STDOUT_FILENO) == -1) {
                    std::cerr << "failed to redirect stdout\n";
                    _exit(126);
                }

                close(pipe_fd[1]);
            }

            const auto exec_arr = get_exec_array(cmd_tokens);
            execvp(exec_arr.at(0), exec_arr.data()); // if successful, it never returns

            // if it returns, then replacing with command contents failed
            std::cerr << "Command not found: " << cmd_tokens.at(0) << "\n";
            _exit(errno == ENONET ? 127 : 126); // terminate child process
        }

        // parent process
        if (output != nullptr) {
            // Parent does not write to the pipe
            close(pipe_fd[1]);

            char buffer[4096];
            ssize_t bytes_read;

            while ((bytes_read = read(pipe_fd[0], buffer, sizeof(buffer))) > 0) {
                output->append(buffer, static_cast<std::size_t>(bytes_read));
            }

            close(pipe_fd[0]);

            if (bytes_read == -1) {
                std::cerr << "Failed to read command output\n";
            }
        }

        // spawn should wait for child process to complete
        // Wait for the child process to finish
        int status;
        while (waitpid(pid, &status, 0) == -1) {
            if (errno != EINTR) {
                std::cerr << "Failed to wait for child process\n";
                break;
            }
        }
    }
} // namespace executor
