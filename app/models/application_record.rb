# @a:id "app/models/application_record.rb#ApplicationRecord"
# @a:summary "Base ActiveRecord model configuration for the application"
# @a:intent "Provide shared behaviour (abstract class) for all models"
# @a:contract {"requires":["inherits from ActiveRecord::Base"],"ensures":["descendants share connection scope","abstract class prevents direct instantiation"]}
# @a:io {"input":{"subclass":"Class inheriting from ApplicationRecord"},"output":{"model":"ActiveRecord::Base descendant"}}
# @a:errors []
# @a:sideEffects "none"
# @a:security "Relies on per-model validations and callbacks"
# @a:perf "No additional overhead beyond ActiveRecord"
# @a:dependencies ["ActiveRecord::Base"]
# @a:example {"ok":"class Widget < ApplicationRecord; end","ng":"ApplicationRecord.new # raises NotImplementedError"}
# @a:cases ["TEST-user-validations-basics","TEST-micropost-validations-basics","TEST-relationship-validations-basics"]
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
