module NcsNavigator::Core::Surveyor
  ##
  # Records responses for a survey.  This is intended to be used by any
  # process in Cases that must deal with filling out surveys.  Examples:
  #
  # - response set prepopulation
  # - tests for operational data extractors
  module SurveyTaker
    ##
    # Records responses for a survey in a given response set.  If the response
    # set is already associated with a survey, you can omit the survey
    # parameter.
    #
    #
    # Usage
    # -----
    #
    # You MUST pass a block to this method.  The block will receive an object
    # for recording answers in the response set.  Usage looks like this:
    #
    #     respond(rs) do |r|
    #       r.answer 'prepopulated_mode_of_contact', 'cati'
    #     end
    #
    # You can set additional data beyond an answer choice:
    #
    #     respond(rs) do |r|
    #       r.answer 'monthly_income', 'other', :value => 9001
    #     end
    #
    # Answers are matched using their reference identifiers, except in
    # the case where only one answer is present for a given question
    # In that case, the reference identifier on the answer is
    # optional:
    #
    #     q_foo 'what?'
    #     a :string
    #     q_foo2 'what?'
    #     a_1 :string
    #
    #     respond(rs) do |r|
    #       r.answer 'foo', :value => 'bar'  # => will fill in "bar" for foo's single answer
    #       r.answer 'foo2', :value => 'bar'  # => will fill in "bar" for foo2's single answer
    #     end
    #
    # If foo had more than one answer a SurveyTaker::UnresolvableAnswer would be raised.
    #
    # By default, questions are also matched using reference identifiers.  If
    # needed, you can use data export identifiers to match questions:
    #
    #     respond(rs) do |r|
    #       r.using_data_export_identifiers do |r|
    #         r.answer "#{BABY_NAME_PREFIX}.BABY_LNAME", :value => person.last_name
    #       end
    #
    #       # Naturally, you can switch back and forth.  This'll use reference
    #       # identifiers.
    #       r.answer "prepopulated_mode_of_contact", "cati"
    #     end
    #
    #
    # Data access behavior
    # --------------------
    #
    # Because surveys can potentially be very large, this method does not
    # perform any database access until the supplied block returns.
    #
    # Once it returns, all referenced questions and answers are retrieved
    # according to their reference or data export identifiers.  Answer lookup
    # is scoped by question.  Responses are then built (not persisted) in the
    # supplied response set.  To save those responses, invoke #save on the
    # response set.
    #
    #
    # Errors raised
    # -------------
    #
    # A SurveyTaker::UnresolvableQuestion will be raised for unresolvable
    # questions.
    # A SurveyTaker::UnresolvableAnswer will be raised for unresolvable
    # answers.
    # A SurveyTaker::AmbiguousAnswer will raised when an answer cannot be
    # unambiguously resolved, i.e. when no answer reference identifier is
    # provided and the question has multiple answers with null reference
    # identifiers.
    #
    # @return [ResponseSet] the given response set, modified
    def respond(rs, survey = rs.survey)
      rs.tap do
        rp = Respondent.new(survey)

        yield rp

        Resolver.new(rp).resolve do |rh|
          rs.responses.build(rh, :as => :system)
        end
      end
    end

    ##
    # @private
    class Respondent
      attr_reader :survey

      ##
      # Promises made on a question's data export identifier.
      attr_reader :dindex

      ##
      # Promises made on a question's reference identifier.
      attr_reader :rindex

      ##
      # All recorded promises.
      attr_reader :promises

      def initialize(survey)
        @dindex = {}
        @promises = []
        @rindex = {}
        @survey = survey
        @index = rindex
      end

      ##
      # Ad-hoc polymorphism can be a mess, so here's a quick refresher on the
      # handled forms of answer:
      #
      #   answer(qref, aref, :value => foo)
      #   answer(qref, aref)
      #   answer(qref, :value => foo)
      def answer(*args)
        if args.length == 3
          valid_keywords!(args[2])
          record(args[0], args[1], args[2][:value])
        elsif args.length == 2
          if args[1].respond_to?(:has_key?)
            valid_keywords!(args[1])
            record(args[0], nil, args[1][:value])
          else
            record(args[0], args[1], nil)
          end
        else
          raise ArgumentError, "wrong number of arguments (#{args.length} for 2 or 3)"
        end
      end

      def using_data_export_identifiers
        begin
          @index = dindex
          yield self
        ensure
          @index = rindex
        end
      end

      private

      def valid_keywords!(kw)
        if !kw.respond_to?(:keys)
          raise ArgumentError, "expected keyword arguments, not #{kw.inspect}"

          if !kw.keys.blank? && kw.keys != [:value]
            raise ArgumentError, "unrecognized keyword arguments: #{kw.keys.inspect}"
          end
        end
      end

      def record(qref, aref, value)
        Response.new(qref, aref, value).tap do |r|
          @index[qref] ||= []
          @index[qref] << r
          @promises << r
        end
      end

      class Response < Struct.new(:qref, :aref, :value, :question, :answer)
        def question_id
          question.id
        end
      end
    end

    ##
    # @private
    class Resolver
      extend Forwardable

      def_delegators :@respondent, :rindex, :dindex, :promises, :survey

      def initialize(respondent)
        @respondent = respondent
      end

      def resolve
        resolve_questions
        resolve_answers

        promises.each do |p|
          yield({ :answer => p.answer, :question => p.question, :value => p.value })
        end
      end

      # Wouldn't it be nice if ActiveRecord scopes handled ORs?
      def resolve_questions
        eds = dindex.keys
        ers = rindex.keys

        qscope = survey.questions
        qd = (qscope.where(:data_export_identifier => eds) unless eds.empty?) || []
        qr = (qscope.where(:reference_identifier => ers) unless ers.empty?) || []

        qrefs_ok!(eds, qd.map(&:data_export_identifier))
        qrefs_ok!(ers, qr.map(&:reference_identifier))

        fulfill(qd, dindex) { |q| q.data_export_identifier }
        fulfill(qr, rindex) { |q| q.reference_identifier }
      end

      def fulfill(questions, index)
        questions.each do |q|
          index[yield q].each { |p| p.question = q }
        end
      end

      def resolve_answers
        resolve_nil_arefs_for_questions_with_one_answer
        ers = promises.map(&:aref)
        eqs = promises.map(&:question_id)

        as = survey.answers.where(:reference_identifier => ers,
                                  :question_id => eqs)

        index = as.group_by { |a| [a.question_id, a.reference_identifier] }

        arefs_ok!(ers, index)

        promises.each do |p|
          p.answer = index[[p.question_id, p.aref]].first
        end
      end

      def resolve_nil_arefs_for_questions_with_one_answer
        index = survey.answers.where(:question_id => promises.map(&:question_id)).group_by(&:question_id)
        promises.select{|p| index[p.question_id].size == 1 && p.aref == nil}.each do |p|
          p.aref = index[p.question_id].first.reference_identifier
        end
      end

      def qrefs_ok!(expected, actual)
        refs_ok!(expected, actual, UnresolvableQuestion)
      end

      def arefs_ok!(expected, aindex)
        refs_ok!(expected, aindex.keys.map(&:last), UnresolvableAnswer)
        unambiguous!(aindex)
      end

      def refs_ok!(expected, actual, error)
        diff = expected - actual

        if !diff.empty?
          raise error, "Unresolvable identifiers: #{diff.inspect}"
        end
      end

      def unambiguous!(aindex)
        ambiguous = aindex.select { |_, c| c.length > 1 }

        if !ambiguous.empty?
          raise AmbiguousAnswer, "Ambiguous (question ID, aref) pairs: #{ambiguous.keys.inspect}"
        end
      end
    end

    class UnresolvableQuestion < StandardError
    end

    class UnresolvableAnswer < StandardError
    end

    class AmbiguousAnswer < StandardError
    end
  end
end
