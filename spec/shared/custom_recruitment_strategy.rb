shared_context 'custom recruitment strategy' do
  around do |example|
    begin
      old_strategy = NcsNavigatorCore.recruitment_strategy
      NcsNavigatorCore.recruitment_strategy = recruitment_strategy
      example.call
    ensure
      NcsNavigatorCore.recruitment_strategy = old_strategy
    end
  end
end
