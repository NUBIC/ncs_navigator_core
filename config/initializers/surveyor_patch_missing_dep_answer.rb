# This is a hasty monkey-patch to work around a combination surveyor issue / NCS
# Navigator instrument definition issue. Some current surveys have dependencies
# whose answers are not resolvable at parse time. This results in a dependency
# condition whose associated answer is nil. DependencyConditionMethods#to_hash
# assumes that every DC has an associated answer. This monkey patch removes that
# assumption.

# This patch should not be necessary after updating to Surveyor 1.0.0 because
# that version has parse-time checks that prevent surveys with bad dependency
# references from being created.

require 'surveyor/models/dependency_condition_methods'

module Surveyor::Models::DependencyConditionMethods
  def to_hash(response_set)
    # all responses to associated question
    responses = question.blank? ? [] : response_set.responses.where("responses.answer_id in (?)", question.answer_ids).all
    if self.operator.match /^count(>|>=|<|<=|=|!=)\d+$/
      op, i = self.operator.scan(/^count(>|>=|<|<=|=|!=)(\d+)$/).flatten
      # logger.warn({rule_key.to_sym => responses.count.send(op, i.to_i)})
      return {rule_key.to_sym => (op == "!=" ? !responses.count.send("==", i.to_i) : responses.count.send(op, i.to_i))}
    elsif operator == "!=" and (responses.blank? or responses.none?{|r| r.answer_id == self.answer_id})
      # logger.warn( {rule_key.to_sym => true})
      return {rule_key.to_sym => true}
    elsif response = responses.detect{|r| r.answer_id == self.answer_id}
      klass = response.answer.response_class
      klass = "answer" if self.as(klass).nil?
      case self.operator
      when "==", "<", ">", "<=", ">="
        # logger.warn( {rule_key.to_sym => response.as(klass).send(self.operator, self.as(klass))})
        return {rule_key.to_sym => response.as(klass).send(self.operator, self.as(klass))}
      when "!="
        # logger.warn( {rule_key.to_sym => !response.as(klass).send("==", self.as(klass))})
        return {rule_key.to_sym => !response.as(klass).send("==", self.as(klass))}
      end
    end
    # logger.warn({rule_key.to_sym => false})
    {rule_key.to_sym => false}
  end
end
