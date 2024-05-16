locals{
  window_app=[for f in fileset("${path.module}/windowsconfig", "[^_]*.yaml") : yamldecode(file("${path.module}/windowsconfig/${f}"))]
  window_app_list = flatten([
    for app in local.window_app : [
      for windowapps in try(app.listofwindowsapp, []) :{
        name=windowapps.name
        os_type=windowapps.os_type
        sku_name=windowapps.sku_name

      }
    ]
])
}

resource "azurerm_resource_group" "azureresourcegroup_windowsapp" {
  name     = "MCIT_lab_session_windowsapp"
  location = "Canada Central"
}

resource "azurerm_service_plan" "windowsbatcha06sp" {
  for_each            ={for sp in local.window_app_list: "${sp.name}"=>sp }
  name                = each.value.name
  resource_group_name = azurerm_resource_group.azureresourcegroup_windowsapp.name
  location            = azurerm_resource_group.azureresourcegroup_windowsapp.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "windowsbatcha06webapp" {
  for_each            = azurerm_service_plan.windowsbatcha06sp
  name                = each.value.name
  resource_group_name = azurerm_resource_group.azureresourcegroup_windowsapp.name
  location            = azurerm_resource_group.azureresourcegroup_windowsapp.location
  service_plan_id     = each.value.id


  site_config {}
}
