//
// Created by davesaah on 03/10/2026.
//
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <string>
#include <vector>

import parser;
import configuration;

using ::testing::ContainerEq;

namespace
{
    struct ParserTestCase {
        std::string test_name;
        std::string input;
        std::vector<std::string> expected_tokens;
    };

    class ParserTest : public ::testing::TestWithParam<ParserTestCase>
    {
    };

    std::string
    PrintTestName(const ::testing::TestParamInfo<ParserTestCase> &info)
    {
        return info.param.test_name;
    }
} // namespace

// Parameterised test
TEST_P(ParserTest, TokenizesInputCorrectly)
{
    const auto &[_, input, expected_tokens] = GetParam();
    EXPECT_THAT(parser::parse_input(input), ContainerEq(expected_tokens));
}

INSTANTIATE_TEST_SUITE_P(
    CommonInputs, ParserTest,
    ::testing::Values(
        ParserTestCase{.test_name = "SimpleCommand",
                       .input = "ls",
                       .expected_tokens = {"ls"}},
        ParserTestCase{.test_name = "SimpleCommandWithArg",
                       .input = "echo world",
                       .expected_tokens = {"echo", "world"}},
        ParserTestCase{.test_name = "MultipleArgumentsWithFlags",
                       .input = "ls -la /tmp",
                       .expected_tokens = {"ls", "-la", "/tmp"}},
        ParserTestCase{.test_name = "ExtraWhitespaceBetweenTokens",
                       .input = "  cat    file.txt   ",
                       .expected_tokens = {"cat", "file.txt"}},
        ParserTestCase{
            .test_name = "EmptyInput", .input = "", .expected_tokens = {}},
        ParserTestCase{.test_name = "OnlyWhitespace",
                       .input = "   \t  ",
                       .expected_tokens = {}},
        ParserTestCase{.test_name = "RemovesQuotes",
                       .input = "echo \"Hello world\"",
                       .expected_tokens = {"echo", "Hello", "world"}},
        ParserTestCase{
            .test_name = "ReplacesRealEnvVariables",
            .input = "echo $HOME",
            .expected_tokens = {"echo",
                                environment::fetch_env("HOME").value()}},
        ParserTestCase{.test_name = "ReplacesFakeEnvVariables",
                       .input = "echo $HOMELAND",
                       .expected_tokens = {"echo", ""}}),
    PrintTestName);
