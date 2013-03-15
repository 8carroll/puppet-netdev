### -----------------------------------------------------------------------------
### junos_personality
### -----------------------------------------------------------------------------

Facter.add(:junos_personality) do
  confine :kernel => :JUNOS
  setcode do
     case Facter.value("hardwaremodel")
     when /^(ex)|(qfx)/
        "JUNOS_switch"
     when /^srx(\d){4}/
        "JUNOS_SRX_HE"
     when /^srx(\d){3}/
        "JUNOS_SRX_branch"
     when /^junosv-firefly/
	"JUNOS_SRX_branch"
     when /^mx|^vmx/
        "JUNOS_MX"
     end
  end
end

### -----------------------------------------------------------------------------
### junos_ifd_style [ 'classis', 'switch' ]
### -----------------------------------------------------------------------------

Facter.add(:junos_ifd_style) do
  confine :kernel => :JUNOS
  setcode { "classic" }
end

Facter.add(:junos_ifd_style) do
  confine :junos_personality => :JUNOS_switch
    
  setcode { "switch" }
end

### -----------------------------------------------------------------------------
### junos_switch_style [ 'vlan', 'bridge_domain', 'vlan_l2ng', 'none' ]
### -----------------------------------------------------------------------------

Facter.add(:junos_switch_style) do
  confine :junos_personality => [:JUNOS_switch, :JUNOS_SRX_branch]  
  setcode do
    case Facter.value("hardwaremodel")
    when /^(ex9)|(ex43)/
      "vlan_l2ng"
    else
      "vlan"
    end
  end
end

Facter.add(:junos_switch_style) do
  confine :junos_personality => [:JUNOS_MX, :JUNOS_SRX_HE]  
  setcode { "bridge_domain" }
end
