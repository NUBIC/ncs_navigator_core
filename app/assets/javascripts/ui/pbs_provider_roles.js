NCSCore.UI.PbsProviderRoleAssociation = function (config) {
  var pbsProviderRolesAttributesForm = new NestedAttributes({
      container: $('.pbs_provider_roles'),
      association: 'pbs_provider_roles',
      content: config.pbsProviderRolesTemplate,
      addHandler: null,
      caller: this
   });
};