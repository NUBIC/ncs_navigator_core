# -*- coding: utf-8 -*-
# The MDES does not have an association for the staff and personnel
# at the provider. This class provides that association.
class PersonnelProviderLink < ActiveRecord::Base

  after_save :ensure_single_primary_contact

  belongs_to :provider
  belongs_to :person

  validates_presence_of :provider
  validates_presence_of :person

  def ensure_single_primary_contact
    if self.primary_contact?
      PersonnelProviderLink.where("id <> ?", self.id).update_all(:primary_contact => false)
    end
  end

end

