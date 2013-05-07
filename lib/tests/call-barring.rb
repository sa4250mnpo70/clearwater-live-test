# @file call-barring.rb
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

TestDefinition.new("Call Barring - Outbound Rejection") do |t|
  sip_caller = t.add_sip_endpoint
  sip_caller.set_simservs ocb: { active: true,
                                 rules: [ { conditions: [],
                                            allow: false } ]
                               }
  sip_callee = t.add_sip_endpoint
  t.set_scenario(
    sip_caller.register +
    sip_callee.register(false) +
    [
      sip_caller.send("INVITE", target: sip_callee),
      sip_caller.recv("100"),
      sip_caller.recv("603"),
      sip_caller.send("ACK", target: sip_caller)
    ] +
    sip_caller.unregister +
    sip_callee.unregister
  )
end

PSTNTestDefinition.new("Call Barring - Allow non-international call") do |t|
  sip_caller = t.add_pstn_endpoint
  sip_caller.set_simservs ocb: { active: true,
                                 rules: [ { conditions: ["international"],
                                            allow: false } ]
                               }
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
      sip_callee.send("200-SDP", target: sip_caller, method: "INVITE"),
      sip_caller.recv("200", rrs: true),
      sip_caller.send("ACK", target: sip_callee, in_dialog: true),
      sip_callee.recv("ACK"),
      SIPpPhase.new("pause", nil, timeout: 1000),
      sip_caller.send("BYE", target: sip_callee, in_dialog: true),
      sip_callee.recv("BYE"),
      sip_callee.send("200", target: sip_caller, method: "BYE", in_dialog: true),
      sip_caller.recv("200"),
    ] +
    sip_caller.unregister +
    sip_callee.unregister
  )
end

PSTNTestDefinition.new("Call Barring - Reject international call") do |t|
  sip_caller = t.add_pstn_endpoint
  sip_caller.set_simservs ocb: { active: true,
                                 rules: [ { conditions: ["international"],
                                            allow: false } ]
                               }
  sip_callee = t.add_fake_endpoint("011447854481549", $domain)
  t.set_scenario(
    sip_caller.register +
    [
      sip_caller.send("INVITE", target: sip_callee),
      sip_caller.recv("100"),
      sip_caller.recv("603"),
      sip_caller.send("ACK", target: sip_caller)
    ] +
    sip_caller.unregister
  )
end

TestDefinition.new("Call Barring - Inbound Rejection") do |t|
  sip_caller = t.add_sip_endpoint
  sip_callee = t.add_sip_endpoint
  sip_callee.set_simservs icb: { active: true,
                                 rules: [ { conditions: [],
                                            allow: false } ]
                               }
  t.set_scenario(
    sip_caller.register +
    sip_callee.register(false) +
    [
      sip_caller.send("INVITE", target: sip_callee),
      sip_caller.recv("100"),
      sip_caller.recv("603"),
      sip_caller.send("ACK", target: sip_caller)
    ] +
    sip_caller.unregister +
    sip_callee.unregister
  )
end