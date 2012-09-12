# -*- coding: utf-8 -*-
module PbsListsHelper

  def provider_recruitment_link(pbs)
    active_provider_recruitment_link(pbs) unless pbs.recruitment_ended?
  end

  def active_provider_recruitment_link(pbs)
    if pbs.recruitment_started?
      txt = 'Continue Provider Recruitment'
    else
      txt = 'Start Provider Recruitment'
    end
    link_to txt, recruit_provider_pbs_list_path(pbs)
  end

end
