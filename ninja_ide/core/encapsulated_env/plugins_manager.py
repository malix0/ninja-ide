# -*- coding: utf-8 -*-
#
# This file is part of NINJA-IDE (http://ninja-ide.org).
#
# NINJA-IDE is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# NINJA-IDE is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NINJA-IDE; If not, see <http://www.gnu.org/licenses/>.

from PyQt4.QtCore import QObject

from ninja_ide.gui.ide import IDE


class PluginsManager(QObject):

    def __init__(self):
        super(PluginsManager, self).__init__()

    def get_activated_plugins(self):
        qsettings = IDE.ninja_settings()
        return qsettings.value('plugins/registry/activated', [])

    def get_failstate_plugins(self):
        qsettings = IDE.ninja_settings()
        return qsettings.value('plugins/registry/failure', [])

    def activate_plugin(self, plugin):
        """
        Receives PluginMetadata instance and activates its given plugin
        BEWARE: We do not do any kind of checking about if the plugin is
        actually installed.
        """
        qsettings = IDE.ninja_settings()
        activated = qsettings.value('plugins/registry/activated', [])
        failure = qsettings.value('plugins/registry/failure', [])

        plugin_name = plugin.name
        try:
            plugin.activate()
        except Exception:
            #This plugin can no longer be activated
            if plugin.name in activated:
                activated.remove(plugin_name)
            if plugin.name not in failure:
                failure.append(plugin_name)
        else:
            activated.append(plugin_name)
            if plugin_name in failure:
                failure.remove(plugin_name)
        finally:
            qsettings.setValue('plugins/registry/activated', activated)
            qsettings.setValue('plugins/registry/failure', failure)