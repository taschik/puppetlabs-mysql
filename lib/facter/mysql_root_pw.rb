require 'facter'
Facter.add(:mysql_root_pw) do
  setcode do
    if File.exist? "/root/.my.cnf"                                                                                                                                               
      Facter::Util::Resolution.exec('cat /root/.my.cnf |grep "password" |awk -F = \'{for(i=2;i<=NF;i++){printf "%s", $i}; printf "\n"}\'')
    end
  end
end