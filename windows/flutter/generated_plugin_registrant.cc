//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <path_provider_plugin.h>
#include <url_launcher_plugin.h>
#include <file_chooser_plugin.h>
#include <window_size_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PathProviderPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PathProviderPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
  FileChooserPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileChooserPlugin"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
}
