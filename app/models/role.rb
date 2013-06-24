# -*- coding: utf-8 -*-


module Role
  ALL_ROLES = [
    SYSTEM_ADMINISTRATOR          = "System Administrator",
    USER_ADMINISTRATOR            = "User Administrator",
    STAFF_SUPERVISOR              = "Staff Supervisor",
    FIELD_STAFF                   = "Field Staff",
    PHONE_STAFF                   = "Phone Staff",
    OUTREACH_STAFF                = "Outreach Staff",
    BIOLOGICAL_SPECIMEN_COLLECTOR = "Biological Specimen Collector",
    SPECIMEN_PROCESSOR            = "Specimen Processor",
    DATA_READER                   = "Data Reader",
    ADMINISTRATIVE_STAFF          = "Administrative Staff"
  ]

  SUPERVISORS = [SYSTEM_ADMINISTRATOR, USER_ADMINISTRATOR, ADMINISTRATIVE_STAFF, STAFF_SUPERVISOR]
end
