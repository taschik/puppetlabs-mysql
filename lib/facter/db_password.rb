require 'facter'
# get all db config file matching the regexp starting with .db_
Dir.foreach('/root') do |item|
  next if item == '.' or item == '..' or not item.match(Regexp.new('\.db_*'))
  # getting the database name
  database = item[4..-5]
  # creating an individual fact containing the database user password for each database
  Facter.add(database) do
    setcode do
      Facter::Util::Resolution.exec('cat /root/%s' % item + ' |grep "password" |awk -F = \'{for(i=2;i<=NF;i++){printf "%s", $i}; printf "\n"}\'')
    end
  end
end