code = NcsNavigator::Core::Configuration.instance.recruitment_type_id
NcsNavigatorCore.recruitment_strategy = RecruitmentStrategy.for_code(code)
