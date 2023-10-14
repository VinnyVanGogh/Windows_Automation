1. Get-ADDomain | fl Name, DomainMode 
# this gets the domain functional level
2. Get-ADDomainController -Discover -Service PrimaryDC
# Gets the Primary dc for a domain
3. Get-ADForest | Select-Object -ExpandProperty GlobalCatalogs
# Get global catalog server
4. Get-ADForest | Select-Object SchemaMaster
# Get Schema Master
5. Get-ADDomainController -Filter {IsReadOnly -eq $true} | Select-Object Name
# Get RODCs (read only dcs)
6. Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
# Get OU's in a domain
7. Get-DhcpServerInDC
# Check For DHCP Servers (Use from DHCP Server)
8. Get-DhcpServerv4Scope | Select-Object Name, ScopeId, State, StartRange, EndRange
# Check DHCP Server stats (Use from DHCP Server)
