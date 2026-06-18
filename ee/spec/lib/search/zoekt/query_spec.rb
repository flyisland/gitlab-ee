# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Search::Zoekt::Query, feature_category: :global_search do
  describe 'initialize' do
    it 'instantiates and can read the attributes' do
      instance = described_class.new('test', source: :api)
      expect(instance.query).to eq 'test'
      expect(instance.source).to eq :api
    end

    context 'when source is not passed' do
      it 'instantiates with nil source and can read the attributes' do
        instance = described_class.new('test')
        expect(instance.query).to eq 'test'
        expect(instance.source).to be_nil
      end
    end

    context 'when query is nil' do
      it 'raises an exception on instance initialization' do
        expect { described_class.new(nil) }.to raise_error(ArgumentError, 'query argument can not be nil')
      end
    end

    context 'when query is not passed' do
      it 'raises an exception on instance initialization' do
        expect { described_class.new }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end
  end

  describe '#formatted_query' do
    using RSpec::Parameterized::TableSyntax

    context 'for exact mode and source is not api' do
      where(:query, :result) do
        ''                              | ''
        'test'                          | 'test'
        '^test.*\b\d+(a|b)[0-9]\sa{3}$' | %q(\^test\.\*\\\b\\\d\+\\(a\|b\\)\[0\-9\]\\\sa\{3\}\$)
        '"foo"'                         | 'foo'
        'lang:ruby    test'             | 'test lang:ruby'
        'case:no test'                  | 'test case:no'
        'foo:bar test'                  | 'foo\:bar\ test'
        'test    case:auto'             | 'test case:auto'
        'case:no test f:dummy.rb'       | 'test case:no f:dummy.rb'
        'case:no test -f:dummy.rb'      | 'test case:no -f:dummy.rb'
        'case:no file:dummy test'       | 'test case:no file:dummy'
        'case:no -file:dummy test'      | 'test case:no -file:dummy'
        'test case:no file:dummy'       | 'test case:no file:dummy'
        'test sym:foo'                  | 'test sym:foo'
        'sym:foo'                       | 'sym:foo'
        'test extension:rb'             | 'test extension:rb'
        '"case:no test"'                | %q(case\:no\ test)
        '"case:no test" lang:ruby'      | %q(case\:no\ test lang:ruby)
        'lang:ruby "case:no test"'      | %q(case\:no\ test lang:ruby)
        '"file:foo" case:yes'           | %q(file\:foo case:yes)
      end

      with_them do
        it 'returns correct exact search query' do
          expect(described_class.new(query).formatted_query(:exact)).to eq result
        end
      end
    end

    context 'for regex mode and source is api' do
      where(:query, :result) do
        'test extension:rb'           | 'test file:\.rb$'
        'test -extension:go'          | 'test -file:\.go$'
        'hello filename:foobar'       | 'hello file:(^|/)foobar$'
        'hello filename:bar.js'       | 'hello file:(^|/)bar\.js$'
        'hello filename:*foo.rb'      | 'hello file:(^|/)[^/]*foo\.rb$'
        'hello filename:*foo.*'       | 'hello file:(^|/)[^/]*foo\.[^/]*$'
        'hello filename:*foo*'        | 'hello file:(^|/)[^/]*foo[^/]*$'
        'te.* -path:hello/world'      | 'te.* -file:(?:^|/)hello\/world'
        'test lang:rb'                | 'test lang:rb'
        '"extension:rb" test'         | 'extension:rb test'
        'test "filename:foo.rb"'      | 'test filename:foo.rb'
        '"extension:rb" extension:rb' | 'extension:rb file:\.rb$'
      end

      with_them do
        it 'returns correct zoekt search query syntax' do
          expect(described_class.new(query, source: :api).formatted_query(:regex)).to eq result
        end
      end
    end

    context 'for unsupported search mode' do
      it 'raises an exception' do
        expect { described_class.new('test').formatted_query(:dummy) }.to raise_error(
          ArgumentError, 'Not a valid search_mode'
        )
      end
    end

    context 'for quoted segments containing filter-like tokens' do
      where(:query, :exact_result, :regex_result) do
        '"file:test'              | %q(file\:test)              | 'file:test'
        '"case:no'                | %q(case\:no)                | 'case:no'
        '"file:test"'             | %q(file\:test)              | 'file:test'
        '"case:no"'               | %q(case\:no)                | 'case:no'
        '"file:a""case:no"'       | %q(file\:a case\:no)        | 'file:a case:no'
        '"-file:test"'            | %q(\-file\:test)            | '-file:test'
        '""'                      | ''                          | ''
        '"" lang:ruby'            | 'lang:ruby'                 | 'lang:ruby'
        '"foo" "bar"'             | 'foo bar'                   | 'foo bar'
        'case:no "file:test" foo' | %q(file\:test foo case:no)  | 'file:test foo case:no'
      end

      with_them do
        it 'treats the quoted content as literal in exact mode' do
          expect(described_class.new(query).formatted_query(:exact)).to eq exact_result
        end

        it 'strips the quotes in regex mode without parsing filter tokens inside them' do
          expect(described_class.new(query).formatted_query(:regex)).to eq regex_result
        end
      end
    end

    context 'for interaction with Filters.by_query_string case-modifier guard' do
      where(:query, :formatted, :triggers_case_modifier) do
        'case:no foo'   | 'foo case:no'     | true
        '"case:no foo"' | %q(case\:no\ foo) | false
        '"case:no"'     | %q(case\:no)      | false
      end

      with_them do
        it 'produces a formatted query whose case-modifier visibility matches expectation', :aggregate_failures do
          result = described_class.new(query).formatted_query(:exact)

          expect(result).to eq(formatted)
          expect(result.match?(/\bcase:(no|yes|auto)\b/)).to eq(triggers_case_modifier)
        end
      end
    end

    context 'for filter tokens without a left-side word boundary' do
      where(:query, :exact_result) do
        'testlang:ruby'   | 'testlang\:ruby'
        'foofile:bar'     | 'foofile\:bar'
        'abccase:no'      | 'abccase\:no'
        '_lang:ruby'      | '_lang\:ruby'
        '1lang:ruby'      | '1lang\:ruby'
        'lang:ruby other' | 'other lang:ruby'
        'foo lang:ruby'   | 'foo lang:ruby'
      end

      with_them do
        it 'does not extract a filter from the middle of a word' do
          expect(described_class.new(query).formatted_query(:exact)).to eq exact_result
        end
      end
    end

    context 'for filters in the middle of a keyword run' do
      where(:query, :exact_result) do
        'foo lang:ruby bar'         | 'foo\ bar lang:ruby'
        'a b c lang:ruby d e'       | 'a\ b\ c\ d\ e lang:ruby'
        'foo lang:ruby file:x bar'  | 'foo\ bar lang:ruby file:x'
        'foo  lang:ruby  bar'       | 'foo\ bar lang:ruby'
      end

      with_them do
        it 'collapses whitespace around the removed filter to a single space' do
          expect(described_class.new(query).formatted_query(:exact)).to eq exact_result
        end
      end
    end

    context 'for repo filter' do
      subject(:repo_filter_query) { described_class.new('repo:foo bar f:test', source: :api).formatted_query(:regex) }

      context 'when repo filter is unavailable' do
        before do
          allow(::Search::Zoekt).to receive(:feature_available?).with(:repo_filter_search).and_return(false)
        end

        it 'treats repo:foo as part of the keyword instead of extracting it as a filter' do
          expect(repo_filter_query).to eq 'repo:foo bar f:test'
        end
      end

      context 'when repo filter is available' do
        before do
          allow(::Search::Zoekt).to receive(:feature_available?).with(:repo_filter_search).and_return(true)
        end

        it 'extracts repo:foo as a filter and appends it after the keyword' do
          expect(repo_filter_query).to eq 'bar repo:foo f:test'
        end
      end
    end
  end
end
