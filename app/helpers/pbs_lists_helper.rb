module PbsListsHelper

  def provider_recruitment_link(pbs)
    if pbs.recruitment_started?
      txt = 'Continue Provider Recruitment'
      cls = 'edit_link icon_link'
    else
      txt = 'Initiate Provider Recruitment'
      cls = 'add_link icon_link'
    end
    link_to txt, recruit_provider_pbs_list_path(pbs), :class => cls
  end

end
