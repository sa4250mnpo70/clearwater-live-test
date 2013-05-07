# @file cancel.rb
#
# Copyright (C) 2013  Metaswitch Networks Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# The author can be reached by email at clearwater@metaswitch.com or by post at
# Metaswitch Networks Ltd, 100 Church St, Enfield EN2 6BQ, UK

TestDefinition.new("CANCEL - Mainline") do |t|
  sip_caller = t.add_sip_endpoint
  sip_callee = t.add_sip_endpoint
  t.set_scenario(
    sip_caller.register +
    sip_callee.register(false) +
    [
      sip_caller.send("INVITE", target: sip_callee),
      sip_caller.recv("100"),
      sip_callee.recv("INVITE", extract_uas_via: true),
      sip_callee.send("100", target: sip_caller, method: "INVITE"),
      sip_callee.send("180", target: sip_caller, method: "INVITE"),
      sip_caller.recv("180"),
      sip_caller.send("CANCEL", target: sip_callee),
      sip_caller.recv("200"),
      sip_callee.recv("CANCEL"),
      sip_callee.send("200", target: sip_caller, method: "CANCEL"),
      sip_callee.send("487", target: sip_caller, method: "INVITE"),
      sip_callee.recv("ACK"),
      sip_caller.recv("487"),
      sip_caller.send("ACK", target: sip_callee),
  ] +
  sip_caller.unregister +
  sip_callee.unregister
  )
end