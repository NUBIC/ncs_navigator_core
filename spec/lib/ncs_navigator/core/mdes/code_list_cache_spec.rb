require 'spec_helper'

module NcsNavigator::Core::Mdes
  describe CodeListCache do
    let(:cache) { CodeListCache.new }

    describe '#code_list' do
      let(:a_list_name) { 'CONFIRM_TYPE_CL2' }
      let(:actual) { cache.code_list(a_list_name) }

      it 'provides a list of codes' do
        actual.collect(&:class).uniq.should == [NcsCode]
      end

      it 'provides the right list of codes' do
        actual.collect(&:list_name).uniq.should == [a_list_name]
      end

      it 'provides all the codes that are in the database' do
        actual.collect(&:local_code).sort.should ==
          NcsCode.where(:list_name => a_list_name).collect(&:local_code).sort
      end

      it 'provides all the codes that are in the database in code order' do
        actual.collect(&:local_code).should ==
          NcsCode.where(:list_name => a_list_name).collect(&:local_code).sort
      end

      it 'returns nil for an unknown list' do
        cache.code_list('fooquux').should be_nil
      end

      it 'returns an unmodifiable list' do
        expect { actual << 'foo' }.to raise_error(/frozen/)
      end

      it 'returns a list containing unmodifiable instances' do
        expect { actual.first.local_code = 18 }.to raise_error(/frozen/)
      end

      it 'only queries once per distinct list requested' do
        expect {
          cache.code_list(a_list_name)
          cache.code_list('CONFIRM_TYPE_CL4')
          cache.code_list('CONFIRM_TYPE_CL4')
          cache.code_list(a_list_name)
          cache.code_list('CONFIRM_TYPE_CL21')
        }.to_not execute_more_queries_than(3)
      end

      describe 'adapting to code reloading' do
        # Classes are only reloaded in development mode, so have to use a
        # subshell to test this.
        def development_mode_check(options={})
          pre_reload_expressions = [*options.delete(:pre_reload)].compact
          post_reload_expressions = [*options.delete(:post_reload)].compact

          script_name = Rails.root + 'tmp' + 'code_list_cache_spec_development_test.rb'

          script_name.open('w') do |f|
            f.puts [
              # insert codes into development database if they aren't already there
              "NcsNavigator::Core::Mdes::CodeListLoader.new(:mdes_version => '#{NcsNavigatorCore.mdes_version.number}').load_from_pg_dump unless NcsCode.count > 0",
              'cache = NcsNavigator::Core::Mdes::CodeListCache.new',
              "cache.code_list(#{a_list_name.inspect}) or fail 'Code list not pre-cached'",
              pre_reload_expressions,
              # this is what reload! in the console does; ditto per-request reloading when cache_classes = false
              "ActionDispatch::Reloader.cleanup!",
              "ActionDispatch::Reloader.prepare!",
              post_reload_expressions
            ].flatten.join("\n")
          end

          cmd = Shellwords.join([
            (Rails.root + 'script' + 'rails').to_s,
            'runner',
            '-e', 'development',
            script_name.to_s
          ])

          result = `#{cmd}`.chomp
          unless $? == 0
            fail "Development-mode subshell failed.\n#{cmd}\n#{result}\n#{script_name.read}"
          end

          result
        end

        before do
          pending 'No development environment in CI' if Rails.env =~ /\Aci/
        end

        it 'reloads instances after a code reload' do
          development_mode_check(
            :post_reload =>
              "puts(cache.code_list(#{a_list_name.inspect}).collect(&:class).uniq == [NcsCode])"
            ).should == 'true'
        end

        it 'gives equivalent codes after a reload' do
          development_mode_check(
            :pre_reload =>
              "original_codes = cache.code_list(#{a_list_name.inspect}).collect(&:local_code)",
            :post_reload =>
              "puts(cache.code_list(#{a_list_name.inspect}).collect(&:local_code) == original_codes)"
            ).should == 'true'
        end

        it 'gives equivalent text after a reload' do
          development_mode_check(
            :pre_reload =>
              "original_codes = cache.code_list(#{a_list_name.inspect}).collect(&:display_text)",
            :post_reload =>
              "puts(cache.code_list(#{a_list_name.inspect}).collect(&:display_text) == original_codes)"
            ).should == 'true'
        end
      end
    end

    describe '#code_value' do
      let(:a_list_name) { 'EVENT_TYPE_CL1' }
      let(:actual) { cache.code_value(a_list_name, 7) }

      it 'provides an NcsCode' do
        actual.should be_a NcsCode
      end

      it 'gives an instance for the right list' do
        actual.list_name.should == a_list_name
      end

      it 'gives an instance for the right code' do
        actual.local_code.should == 7
      end

      it 'gives nil for an unknown list' do
        cache.code_value('bar', 1).should be_nil
      end

      it 'gives nil for an unknown code' do
        cache.code_value(a_list_name, -100000).should be_nil
      end

      it 'returns unmodifiable instances' do
        expect { actual.display_text = 'Something else' }.to raise_error(/frozen/)
      end

      it 'only queries once per code list' do
        expect {
          cache.code_value('CONFIRM_TYPE_CL3', 1)
          cache.code_value('EVENT_TYPE_CL1', 9)
          cache.code_value('CONFIRM_TYPE_CL4', 2)
          cache.code_value('EVENT_TYPE_CL1', 23)
          cache.code_value('EVENT_TYPE_CL1', 27)
          cache.code_value('EVENT_TYPE_CL1', 29)
        }.to_not execute_more_queries_than(3)
      end
    end

    describe '#reset' do
      it 'triggers a reload of a loaded code list' do
        expect {
          cache.code_list('CONFIRM_TYPE_CL2')
          cache.reset
          cache.code_list('CONFIRM_TYPE_CL2')
        }.to execute_more_queries_than(1)
      end
    end
  end
end
