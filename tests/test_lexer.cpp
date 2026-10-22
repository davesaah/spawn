//
// Created by davesaah on 22/10/2026.
//
#include <gmock/gmock.h>
#include <gtest/gtest.h>
import token;
import lexer;
using ::testing::ContainerEq;

namespace
{
    struct LexerTestCase {
        std::string test_name;
        std::string input;
        token::TokenType expected_type;
    };

    class LexerTest : public ::testing::TestWithParam<LexerTestCase>
    {
    };

    std::string PrintTestName(const ::testing::TestParamInfo<LexerTestCase>& info)
    {
        return info.param.test_name;
    }
} // namespace

TEST_P(LexerTest, CheckingTokens)
{
    const auto& [_, input, expected_type] = GetParam();
    const auto l = lexer::lexer(input);
    EXPECT_EQ(l.get_next_token().type, expected_type);
}

INSTANTIATE_TEST_SUITE_P(
    CommonInputs, LexerTest,
    ::testing::Values(
        LexerTestCase{.test_name = "ExitKeyword", .input = "exit", .expected_type = token::Keyword::EXIT},
        LexerTestCase{.test_name = "ExportKeyword", .input = "export", .expected_type = token::Keyword::EXPORT},
        LexerTestCase{.test_name = "HistoryKeyword", .input = "history", .expected_type = token::Keyword::HISTORY},
        LexerTestCase{.test_name = "PipeSymbol", .input = "|", .expected_type = token::Symbol::PIPE},
        LexerTestCase{.test_name = "EqualsSymbol", .input = "=", .expected_type = token::Symbol::EQUALS}),
    PrintTestName);

namespace
{
    struct LexerCmdTestCase {
        std::string test_name;
        std::string input;
        std::vector<token::TokenType> expected_types;
    };

    class LexerCmdTest : public ::testing::TestWithParam<LexerCmdTestCase>
    {
    };

    std::string PrintCmdTestName(const ::testing::TestParamInfo<LexerCmdTestCase>& info)
    {
        return info.param.test_name;
    }

} // namespace
TEST_P(LexerCmdTest, CheckingCommandTokens)
{
    const auto& [_, input, expected_types] = GetParam();
    const auto l = lexer::lexer(input);

    std::vector<token::TokenType> token_types;

    for (auto _token = l.get_next_token(); _token.type != token::TokenType{token::Symbol::END};
         _token = l.get_next_token()) {
        token_types.push_back(_token.type);
    }

    EXPECT_THAT(token_types, ContainerEq(expected_types));
}

INSTANTIATE_TEST_SUITE_P(
    CommonInputs, LexerCmdTest,
    ::testing::Values(LexerCmdTestCase{.test_name = "EchoProgram",
                                       .input = "echo hello",
                                       .expected_types = {token::Shell::COMMAND, token::Shell::ARGUMENT}},
                      LexerCmdTestCase{
                          .test_name = "LsProgram", .input = "ls", .expected_types = {token::Shell::COMMAND}}),
    PrintCmdTestName);
