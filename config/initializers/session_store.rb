# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_COCTS_session',
  :secret      => 'ce56bc9166bfb076ddf374e33850c441413e8fce596b2d45891340ff25ae00ebed637312c90593dc3d1b8cdde456bec1dd54cdda7b9ae3a690c8b8ce07ecaeca'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
