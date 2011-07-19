def self.check_errors(record)
  if record.errors.size > 0
    puts "Error in #{record.class}:"
    puts record.errors.full_messages.join("\n")
    return false
  else
    puts "#{record.class} ... [OK]"
    return true
  end
end

user = User.create(
  :name => 'Administrador',
  :lastname => 'Administrador',
  :email => 'admin@cocts.edu',
  :enable => true,
  :admin => true,
  :user => 'admin',
  :password => 'admin123'
)

check_errors user
