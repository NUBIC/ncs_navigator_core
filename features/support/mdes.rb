# Some scenarios need to modify characteristics of the singleton MDES
# specification used by Cases.  For example, api/code_lists.feature needs to
# control timestamps on the disposition codes source file.
#
# This hook wraps a scenario with a fresh MDES::Specification object that can
# be modified as necessary, and then restores the original spec once the
# scenario is done.
Around('@mdes') do |scenario, block|
  begin
    current = NcsNavigatorCore.configuration.mdes_version.specification
    new = NcsNavigator::Mdes(NcsNavigatorCore.configuration.mdes_version.number)
    NcsNavigatorCore.configuration.mdes_version.specification = new
    block.call
  ensure
    NcsNavigatorCore.configuration.mdes_version.specification = current
  end
end
