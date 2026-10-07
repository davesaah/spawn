//
// Created by davesaah on 03/10/2026.
//
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <iostream>
#include <sstream>

import configuration;

using ::testing::Eq;
using ::testing::IsEmpty;

namespace
{
    // Fixture class to isolate setup and stream redirection
    class HistoryTest : public ::testing::Test
    {
      protected:
        std::ostringstream captured_stream;
        std::streambuf *old_cout_buffer{nullptr};
        history::HistoryState history;

        // runs before each test begins
        void SetUp() override
        {
            old_cout_buffer = std::cout.rdbuf(captured_stream.rdbuf());
            history.ensure_state();
        }

        // runs after each test is done
        void TearDown() override
        {
            history.clear();
            std::cout.rdbuf(old_cout_buffer);
        }
    };
} // namespace

TEST_F(HistoryTest, ClearsHistoryState)
{
    history.clear();
    history.display();
    EXPECT_THAT(captured_stream.str(), IsEmpty());
}

TEST_F(HistoryTest, DisplaysAppendedEntriesInOrder)
{
    history.append("echo hello");
    history.append("pwd");

    history.display();

    const std::string expected_output = "echo hello\n"
                                        "pwd\n";

    EXPECT_THAT(captured_stream.str(), Eq(expected_output));
}
